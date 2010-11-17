require 'sinatra/base'
require 'base64'
require 'json'
require 'uuid'

module Simplenote
  class Server < Sinatra::Base
    set :app_file, __FILE__

    configure do
      set :email, "test@example.com"
      set :password, "Simplenote"
      set :token, "4AD2AB0C69C862309C53B1668271950CA026B11A4501E9E6F59D3617026865C5"
      set :datastore, File.join(File.dirname(__FILE__), "notes")
      Dir.mkdir datastore unless Dir.exists? datastore
    end

    helpers do
      def check_authorization
        halt 401 unless(params['auth'] == options.token && params['email'] == options.email)
      end

      def note_path(key)
        File.join(options.datastore, key + ".json")
      end

      def get_note(key)
        path = note_path key
        if File.exists? path
          JSON.parse(File.read path)
        else
          nil
        end
      end

      def set_note(key, note)
        path = note_path key
        File.open(path, 'w') do |f|
          f.write note
        end
      end

      def all_notes
        Dir[File.join(options.datastore, '*.json')].map do |path|
          JSON.parse(File.read path)
        end
      end

      def filter_note(note)
        filtered = {}
        %w[content deleted modifydate createdate systemtags tags].each do |key|
          filtered[key] = note[key] if note.has_key?(key)
        end
        filtered
      end
    end

    post '/api/login' do
      decoded_body = Base64.decode64 request.body.read
      parsed_body = Rack::Utils.parse_query(decoded_body)
      if parsed_body['email'] == options.email && parsed_body['password'] == options.password
        return options.token
      end

      halt 400
    end

    # Create note
    post '/api2/data' do
      content_type :json
      check_authorization

      key = UUID.generate
      defaults = {
        'key' => key,
        'version' => 1,
        'syncnumber' => 1,
        'minversion' => 1,
        'deleted' => 0,
        'modifydate' => Time.now.to_f.to_s,
        'createdate' => Time.now.to_f.to_s,
        'tags' => [],
        'systemtags' => []
      }
      note = filter_note(JSON.parse request.body.read)
      note = defaults.merge(note).to_json

      set_note key, note
      note
    end

    # Get note
    get '/api2/data/:key' do |key|
      content_type :json
      check_authorization

      note = get_note key
      halt 404 if note.nil?

      note.to_json
    end

    # Update note
    post '/api2/data/:key' do |key|
      content_type :json
      check_authorization

      note = get_note key
      halt 404 if note.nil?

      note.merge! filter_note(JSON.parse request.body.read)
      note['version'] += 1
      note['syncnumber'] += 1

      # TODO: Exclude content if it hasn't changed
      note = note.to_json
      set_note note['key'], note
      note
    end

  end
end
