connection = Crawlr::Model::ApplicationRecord.connection

# connection.create_database('crawlr') unless connection.table_exists?('crawlr')

connection.create_table('web_sites', force: true) do |t|
  t.string :host, null: false
  t.string :path_prefix, null: false
  t.integer :protocol, default: 0

  t.index [:host, :path_prefix], unique: true
end

connection.create_table('ignore_path_patterns', force: true) do |t|
  t.references :web_site, null: false
  t.string :regexp_string, null: false
  t.integer :maximum_count, default: 1, null: false
  t.integer :count, default: 0, null: false

  t.index [:web_site_id, :regexp_string], unique: true
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
  t.integer :priority, default: 0, null: false
  t.integer :state, default: 0, null: false
  t.index [:web_site_id, :http_method, :url], unique: true
end

connection.create_table('web_page_sessions', force: true) do |t|
  t.references :web_page, null: false, index: false
  t.string :title, null: false
  t.text :html, null: false

  t.index [:web_page_id], unique: true
end


web_site = Crawlr::Model::WebSite.from_url('https://payroll.moneyforward.com/')
web_site.save!

id = '(?:(?![_-])(\w+)[_-](\w+)(?<![_-])|\d+)'

%W[
  https://support.biz.moneyforward.com/
  https://payroll.moneyforward.com/banks/#{id}/branches
  https://payroll.moneyforward.com/employees/#{id}/employee_payment_method_bonus_remained_amount/edit
  https://payroll.moneyforward.com/payroll_progresses/#{id}
  https://payroll.moneyforward.com/periods/#{id}/edit
  https://payroll.moneyforward.com/periods/#{id}/fb_data/new
  https://payroll.moneyforward.com/periods/#{id}/multiple_finalized_payrolls/edit
  https://payroll.moneyforward.com/periods/#{id}/payroll_finalization_queues/new
  https://payroll.moneyforward.com/periods/#{id}/payrolls
  https://payroll.moneyforward.com/periods/#{id}/resident_tax_fb_data/new
  https://payroll.moneyforward.com/reports/periods/#{id}/payroll_transfer_amount_statements
  https://payroll.moneyforward.com/reports/periods/#{id}/levied_resident_tax_amount_statements
  https://payroll.moneyforward.com/reports/periods/#{id}/department_payment_deductions
].each do |regexp|
  web_site.ignore_path_patterns.find_or_create_by!(regexp_string: regexp, maximum_count: 1)
end
