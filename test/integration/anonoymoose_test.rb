require 'minitest/autorun'
require 'rack/test'
require_relative '../../app'

class AnonymooseTest < Minitest::Test
  include Rack::Test::Methods

  UPLOAD_DIR = 'uploads'

  def app
    Anonymoose.new
  end

  def setup
    FileUtils.mkdir_p(UPLOAD_DIR)
    # Create a test file
    File.open('test/test.txt', 'w') { |file| file.write("test content") }
  end

  def teardown
    FileUtils.rm_rf(UPLOAD_DIR)
    # Clean up the test file
    File.delete('test/test.txt') if File.exist?('test/test.txt')
  end

  def test_home_page
    get '/'
    assert last_response.ok?
    assert_includes last_response.body, 'Welcome to Anonymoose'
  end

  def test_upload_page
    get '/upload'
    assert last_response.ok?
    assert_includes last_response.body, 'Upload a File'
  end

  def test_file_upload
    file = Rack::Test::UploadedFile.new('test/test.txt', 'text/plain')
    post '/upload', { file: file, expiration: '15' }

    assert last_response.ok?
    assert_includes last_response.body, 'Upload Success'
  end
end
