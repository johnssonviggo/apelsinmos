require_relative 'spec_helper'
require_relative '../lib/request'

describe 'Request' do

    describe 'Simple get-request' do

        it 'parses the http method' do
            request_string = File.read('./test/example_requests/get-index.request.txt')
            request = Request.new(request_string)
            _(request.method).must_equal :get
        end

        it 'parses the resource' do
            request_string = File.read('./test/example_requests/get-index.request.txt')
            request = Request.new(request_string)
            _(request.resource).must_equal "/"
        end


    end

    describe 'Simple post-request' do

        it 'parses the http method' do
            request_string = File.read('./test/example_requests/post-login.request.txt')
            request = Request.new(request_string)
            _(request.method).must_equal :post
        end

        it 'parses the resource' do
            request_string = File.read('./test/example_requests/post-login.request.txt')
            request = Request.new(request_string)
            _(request.resource).must_equal "/login"
        end


    end

    describe 'Simple get-request' do

        it 'parses the http method' do
            request_string = File.read('./test/example_requests/get-examples.request.txt')
            request = Request.new(request_string)
            _(request.method).must_equal :get
        end

        it 'parses the resource' do
            request_string = File.read('./test/example_requests/get-examples.request.txt')
            request = Request.new(request_string)
            _(request.resource).must_equal "/examples"
        end


    end


    describe 'Simple get_filter-request' do

        it 'parses the http method' do
            request_string = File.read('./test/example_requests/get-fruits-with-filter.request.txt')
            request = Request.new(request_string)
            _(request.method).must_equal :get
        end

        it 'parses the resource' do
            request_string = File.read('./test/example_requests/get-fruits-with-filter.request.txt')
            request = Request.new(request_string)
            _(request.resource).must_equal "/fruits?type=bananas&minrating=4"
        end

        it 'parses the headers' do
            request_string = File.read('./test/example_requests/get-fruits-with-filter.request.txt')
            headers = {"Host" => "fruits.com",
            "User-Agent" => "ExampleBrowser/1.0",
            "Accept-Encoding" => "gzip, deflate",
            "Accept" => "*/*"}
            request = Request.new(request_string)
            _(request.headers).must_equal headers
        end

        it 'parses the params' do
            request_string = File.read('./test/example_requests/get-fruits-with-filter.request.txt')
            params = {"type" => "bananas", "minrating" => "4"}
            request = Request.new(request_string)
            _(request.params).must_equal params
        end
        
        # it 'parses the params' do
        #     request_string = File.read('test/example_requests/post-login.request.txt')
        #     params = {"type" => "bananas", "minrating" => "4"}
        #     request = Request.new(request_string)
        #     _(request.params).must_equal params
        # end
    end

end
