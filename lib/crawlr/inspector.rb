module Crawlr
  class Inspector
    attr_reader :web_site

    IGNORE_PARAM_NAMES = %w[utf8 authenticity_token commit]

    def initialize(web_site)
      @web_site = web_site
    end

    def start
      batch_forms!
    end

    private

    def batch_forms!
      tables = Hash.new { |hash, table_name| hash[table_name] = Table.new(table_name) }

      web_site.form_patterns.each do |form_pattern|
        model_param_keys = form_pattern.params.slice(*(form_pattern.params.keys - IGNORE_PARAM_NAMES))
        params = Rack::Utils.default_query_parser.make_params

        model_param_keys.each do |key, value|
          Rack::Utils.default_query_parser.normalize_params(params, key, value, Rack::Utils.default_query_parser.param_depth_limit)
        end

        model_name = RailsUri.new(form_pattern.action.presence || form_pattern.web_page.url).current_namespace
        parse_params_to_model(tables, params.to_params_hash, model_name)
      end

      web_site.form_patterns.map(&:action).each do |url|
        add_resource_id_from_url(tables, url)
      end

      web_site.web_pages.done.map(&:url).each do |url|
        add_resource_id_from_url(tables, url)
      end

      tables.values.each do |table|
        foreign_keys = table.attributes.select { |attribute| attribute.end_with?('_id') }

        foreign_keys.each do |foreign_key|
          table_name = foreign_key.remove('_id').tableize
          tables[table_name].has_many.add(table)
        end
      end

      File.open('/tmp/result', 'w') do |output|
        tables.values.each do |table|
          next if table.no_data?

          output.puts("[#{table.table_name.tableize}]")
          table.attributes.each do |attribute|
            # unless 以下はバグ 調査してない
            output.puts(attribute.gsub('-', '_').remove('.'))
          end

          output.puts('')
        end

        tables.values.each do |table|
          table.has_many.each do |to|
            output.puts("#{table.table_name.tableize} 1--* #{to.table_name.tableize}")
          end
        end
      end

      file_name = SecureRandom.hex
      file_path = "/tmp/#{file_name}"
      Crawlr::Erd.execute(input: '/tmp/result', output: file_path)

      system('open', file_path)
    end

    def add_resource_id_from_url(tables, url)
      hierarchy_params = RailsUri.new(url).to_hierarchy_params
      hierarchy_params.each do |from, column_names|
        column_names.each do |column_name|
          tables[from.to_s.tableize].attributes.add(column_name.to_s.remove('.'))
        end
      end
    end

    def parse_params_to_model(tables, params, model_name = nil)
      (params || {}).each do |key, value|
        if maybe_attribute?(key, value)
          tables[model_name].attributes.add(key.remove('.'))
        elsif value.is_a?(Hash) && value.keys.all? { |v| v =~ /\d+/ }
          if hash = value.values.find { |a| a.is_a?(Hash) }
            parse_params_to_model(tables, value.values.first, normalize_nested_attribute(key))
          else
            tables[model_name].attributes.add(key.remove('.'))
          end
        else
          parse_params_to_model(tables, value, normalize_nested_attribute(key))
        end
      end
    end

    def normalize_nested_attribute(key_name)
      if key_name.end_with?('_attributes')
        key_name.remove(/_attributes$/)
      else
        key_name
      end
    end

    def maybe_attribute?(key, value)
      if value.is_a?(String)
        true
      else
        false
      end
    end
  end
end
