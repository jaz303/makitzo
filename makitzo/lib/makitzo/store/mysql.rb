require 'mysql2'

module Makitzo; module Store
  class MySQL
    attr_accessor :host, :port, :socket, :username, :password, :database
    
    def initialize(config = {})
      config.each { |k,v| send(:"#{k}=", v) }
      @mutex = Mutex.new
    end
    
    def open(&block)
      connect!
      begin
        yield if block_given?
      ensure
        cleanup!
      end
    end
    
    def read(host, key)
      sync do
        @client.query("SELECT * FROM #{key_value_table} WHERE hostname = #{qs(host)} AND `key` = #{qs(key)}", :cast_booleans => true).each do |r|
          return row_value(r)
        end
        nil
      end
    end
    
    def write(host, key, value)
      value_hash = {
        'value_int'       => 'NULL',
        'value_float'     => 'NULL',
        'value_date'      => 'NULL',
        'value_datetime'  => 'NULL',
        'value_boolean'   => 'NULL',
        'value_string'    => 'NULL'
      }
      
      case value
      when Fixnum                 then  value_hash['value_int'] = value.to_s
      when Float                  then  value_hash['value_float'] = value.to_s
      when DateTime, Time         then  value_hash['value_datetime'] = qs(value.strftime("%Y-%m-%dT%H:%M:%S"))
      when Date                   then  value_hash['value_date'] = qs(value.strftime("%Y-%m-%d"))
      when TrueClass, FalseClass  then  value_hash['value_boolean'] = value ? '1' : '0'
      when NilClass               then  ; # do nothing
      else                              value_hash['value_string'] = qs(value)
      end
      
      sync do
        @client.query("
          REPLACE INTO #{key_value_table}
            (hostname, `key`, value_int, value_float, value_date, value_datetime, value_boolean, value_string)
          VALUES
            (#{qs(host)}, #{qs(key)}, #{value_hash['value_int']}, #{value_hash['value_float']},
             #{value_hash['value_date']}, #{value_hash['value_datetime']}, #{value_hash['value_boolean']},
             #{value_hash['value_string']})
        ")
      end
    end
    
    def read_all(host, *keys)
      out = [keys].flatten.inject({}) { |hsh,k| hsh[k.to_s] = nil; hsh }
      sync do
        @client.query("SELECT * FROM #{key_value_table} WHERE hostname = #{qs(host)} AND `key` IN (#{out.keys.map { |k| qs(k) }.join(', ')})", :cast_booleans => true).each do |r|
          out[r['key']] = row_value(r)
        end
      end
      out
    end
    
    def write_all(host, hash)
      sync do
        hash.each { |k,v| write(host, k, v) }
      end
    end
    
    def mark_migration_as_applied(host, migration)
      sync do
        @client.query("REPLACE INTO #{migrations_table} (hostname, migration_id) VALUES (#{qs(host)}, #{migration.to_i})")
      end
    end
    
    def unmark_migration_as_applied(host, migration)
      sync do
        @client.query("DELETE FROM #{migrations_table} WHERE hostname = #{qs(host)} AND migration_id = #{migration.to_i}")
      end
    end
    
    def applied_migrations_for_all_hosts
      sync do
        @client.query("SELECT * FROM #{migrations_table} ORDER BY migration_id ASC").inject({}) do |m,r|
          (m[r['hostname']] ||= []) << r['migration_id']
          m
        end
      end
    end
    
    def applied_migrations_for_host(host)
      sync do
        @client.query("SELECT migration_id FROM #{migrations_table} WHERE hostname = #{qs(host)} ORDER BY migration_id ASC").inject([]) do |m,r|
          m << r['migration_id']
        end
      end
    end
    
    private
    
    def sync(&block)
      @mutex.synchronize(&block)
    end
    
    def row_value(r)
      r['value_int'] || r['value_float'] || r['value_string'] || r['value_date'] || r['value_datetime'] || r['value_boolean']
    end
    
    def qs(str)
      "'#{@client.escape(str.to_s)}'"
    end
    
    def connect!
      @client = Mysql2::Client.new(connection_hash)
      create_tables! unless tables_exist?
    end
    
    def cleanup!
      @client.close if @client
    end
    
    def connection_hash
      %w(host port socket username password database).inject({}) { |m,k| m[k.to_sym] = send(k); m }
    end
    
    def migrations_table
      "makitzo_applied_migrations"
    end
    
    def key_value_table
      "makitzo_key_values"
    end
    
    def tables_exist?
      (@client.query("SHOW TABLES").map { |r| r.values.first } & [migrations_table, key_value_table]).length == 2
    end
    
    def create_tables!
      @client.query("DROP TABLE IF EXISTS #{migrations_table}")
      @client.query("DROP TABLE IF EXISTS #{key_value_table}")
      
      sql = <<-SQL
        CREATE TABLE `#{migrations_table}` (
          `hostname` varchar(255) NOT NULL,
          `migration_id` int(11) NOT NULL,
          `hash` varchar(255) NULL,
          PRIMARY KEY (`hostname`,`migration_id`)
        ) ENGINE=InnoDB
      SQL
      @client.query(sql)
      
      sql = <<-SQL
        CREATE TABLE `#{key_value_table}` (
          `hostname` varchar(255) NOT NULL,
          `key` varchar(255) NOT NULL,
          `value_int` int(11) DEFAULT NULL,
          `value_float` float DEFAULT NULL,
          `value_string` varchar(255) DEFAULT NULL,
          `value_date` date DEFAULT NULL,
          `value_datetime` datetime DEFAULT NULL,
          `value_boolean` tinyint(1) DEFAULT NULL,
          PRIMARY KEY (`hostname`,`key`)
        ) ENGINE=InnoDB
      SQL
      @client.query(sql)
    end
  end
end; end
