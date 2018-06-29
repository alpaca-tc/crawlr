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

        parse_params_to_model(tables, params.to_params_hash)
      end

      web_site.form_patterns.map(&:action).each do |url|
        add_resource_id_from_url(tables, url)
      end

      # web_site.web_pages.done.map(&:url).each do |url|
      #   add_resource_id_from_url(tables, url)
      # end

      File.open('/tmp/result', 'w') do |output|
        tables.values.each do |table|
          output.puts("[#{table.table_name.tableize}]")
          table.attributes.each do |attribute|
            output.puts(attribute)
          end

          output.puts('')
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
          tables[from.to_s.tableize].attributes.add(column_name.to_s)
        end
      end
    end

    def parse_params_to_model(tables, params, model_name = nil)
      params.each do |key, value|
        if maybe_attribute?(key, value)
          tables[model_name].attributes.add(key) if model_name
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
