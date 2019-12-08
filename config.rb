# frozen_string_literal: true

module Config
  def self.db
    Sequel.connect(
      host:     '127.0.0.1',
      user:     ENV['PGUSER'],
      adapter:  'postgres',
      database: 'roda_app_development',
      password: ENV['PGPASSWORD']
    )
  end
end
