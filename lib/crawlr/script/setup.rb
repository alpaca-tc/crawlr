connection = Crawlr::Model::ApplicationRecord.connection

# connection.create_database('crawlr') unless connection.table_exists?('crawlr')

connection.create_table('web_sites', force: true) do |t|
  t.string :host, null: false
  t.string :path_prefix, null: false
  t.integer :protocol, default: 0

  t.index [:host, :path_prefix], unique: true
end
