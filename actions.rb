module Actions
  #https://github.com/thoughtbot/suspenders/blob/master/lib/suspenders/actions.rb
  
  def concat_file(source, destination)
    contents = IO.read(find_in_source_paths(source))
    append_file destination, contents
  end

  def replace_in_file(relative_path, find, replace)
    path = File.join(destination_root, relative_path)
    contents = IO.read(path)
    unless contents.gsub!(find, replace)
      raise "#{find.inspect} not found in #{relative_path}"
    end
    File.open(path, "w") { |file| file.write(contents) }
  end

  def action_mailer_host(rails_env, host)
    inject_into_file(
      "config/environments/#{rails_env}.rb",
      "\n\n  config.action_mailer.default_url_options = { :host => '#{host}' }",
      :before => "\nend"
    )
  end

  def download_file(uri_string, destination)
    uri = URI.parse(uri_string)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true if uri_string =~ /^https/
    request = Net::HTTP::Get.new(uri.path)
    contents = http.request(request).body
    path = File.join(destination_root, destination)
    File.open(path, "w") { |file| file.write(contents) }
  end

  #stuff copied from https://github.com/ffmike/BigOldRailsTemplate/blob/master/template_framework.rb

  # Heroku management
  # Run a command with the Heroku gem.
  #
  # ==== Examples
  #
  #   heroku :create
  #   heroku :rake => "db:migrate"
  #
  def heroku(command = {})
    in_root do
      if command.is_a?(Symbol)
        log 'running', "heroku #{command}"
        run "heroku #{command}"
      else
        command.each do |command, options|
          log 'running', "heroku #{command} #{options}"
          run("heroku #{command} #{options}")
        end
      end
    end
  end

  # File Management
  def download(from, to = from.split("/").last)
    #run "curl -s -L #{from} > #{to}"
    file to, open(from).read
  rescue
    puts "Can't get #{from} - Internet down?"
    exit!
  end

  # grab an arbitrary file from github
  def file_from_repo(github_user, repo, sha, filename, to = filename)
    download("http://github.com/#{github_user}/#{repo}/raw/#{sha}/#{filename}", to)
  end

  def load_from_file_in_template(file_name, parent_binding = nil, file_group = 'default', file_type = :pattern)
    base_name = file_name.gsub(/^\./, '')
    begin
      if file_type == :config
        contents = {}
      else
        contents = ''
      end
      paths = template_paths

      paths.each do |template_path|
        full_file_name = File.join(template_path, file_type.to_s.pluralize, file_group, base_name)
        debug_log "Searching for #{full_file_name} ... "

        next unless File.exists? full_file_name
        debug_log "Found!"

        if file_type == :config
          contents = open(full_file_name) { |f| YAML.load(f) }
        else
          contents = open(full_file_name) { |f| f.read }
        end
        if contents && parent_binding
          contents = eval("\"" + contents.gsub('"','\\"') + "\"", parent_binding)
        end
        # file loaded, stop searching
        break if contents

      end
      contents
    rescue => ex
      debug_log "Error in load_from_file_in_template #{file_name}"
      debug_log ex.message
    end
  end

  # Load a snippet from a file
  def load_snippet(snippet_name, snippet_group = "default", parent_binding = nil)
    load_from_file_in_template(snippet_name, parent_binding, snippet_group, :snippet)
  end

  # Load a pattern from a file, potentially with string interpolation
  def load_pattern(pattern_name, pattern_group = "default", parent_binding = nil)
    load_from_file_in_template(pattern_name, parent_binding, pattern_group, :pattern)
  end

  # YAML.load a configuration from a file
  def load_template_config_file(config_file_name, config_file_group = template_identifier)
    load_from_file_in_template(config_file_name, nil, config_file_group, :config )
  end
end