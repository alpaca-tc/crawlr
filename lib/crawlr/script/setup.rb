connection = Crawlr::Model::ApplicationRecord.connection

# connection.create_database('crawlr') unless connection.table_exists?('crawlr')

connection.create_table('web_sites', force: true) do |t|
  t.string :host, null: false
  t.string :path_prefix, null: false
  t.integer :protocol, default: 0

  t.index [:host, :path_prefix], unique: true
end

connection.create_table('path_patterns', force: true) do |t|
  t.references :web_site, null: false
  t.string :raw_url, null: false
  t.string :pattern, null: false

  t.index [:web_site_id, :raw_url], unique: true
end

connection.create_table('form_patterns', force: true) do |t|
  t.references :web_page, null: false
  t.string :xpath, null: false
  t.string :action, null: false
  t.boolean :skipped, default: false
  t.text :params
end

connection.create_table('web_pages', force: true) do |t|
  t.references :web_site, null: false
  t.integer :http_method, null: false
  t.string :url, null: false
  t.integer :state, default: 0, null: false
  t.index [:web_site_id, :http_method, :url], unique: true
end

connection.create_table('web_page_sessions', force: true) do |t|
  t.references :web_page, null: false, index: false
  t.string :title, null: false
  t.text :html, null: false

  t.index [:web_page_id], unique: true
end
