connection = Crawlr::Model::ApplicationRecord.connection

%w[
  web_sites
].each do |table_name|
  connection.drop_table(table_name) if connection.table_exists?(table_name)
end
