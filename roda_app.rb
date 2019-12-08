# frozen_string_literal: true

require 'roda'
require 'sequel'
require 'bcrypt'
require 'dotenv/load'
require 'rack/protection'

Sequel.connect(
  host:     '127.0.0.1',
  user:     ENV['PGUSER'],
  adapter:  'postgres',
  database: 'roda_app_development',
  password: ENV['PGPASSWORD']
)

class RodaApp < Roda
  Sequel::Model.plugin :validation_helpers
  Sequel::Model.plugin :timestamps, update_on_create: true # To populate timestamps on record creation

  use Rack::Session::Cookie, secret: 'some_nice_long_random_string_DSKJH4378EYR7EGKUFH', key: '_roda_app_session'
  use Rack::Protection
  plugin :csrf

  require './models/user.rb'

  plugin :static, ['/images', '/css', '/js']
  plugin :render
  plugin :head
  route do |r|
    r.root do
      @posts = Post.reverse_order(:created_at)
      view('homepage')
    end

    r.get 'about' do
      view('about')
    end

    r.get 'contact' do
      view('contact')
    end
    ##================================================== USER  ==================================================##

    r.get 'login' do
      view('login')
    end

    r.post 'login' do
      if user = User.authenticate(r['email'], r['password'])
        session[:user_id] = user.id
        r.redirect '/'
      else
        r.redirect '/login'
      end
    end

    r.post 'logout' do
      session.clear
      r.redirect '/'
    end

    r.redirect '/login' unless session[:user_id]

    r.on 'users' do
      r.get 'new' do
        @user = User.new
        view('users/new')
      end

      r.get ':id' do |id|
        @user = User[id]
        view('users/show')
      end

      r.is do
        r.get do
          @users = User.order(:id)
          view('users/index')
        end

        r.post do
          @user = User.new(r['user'])
          if @user.valid? && @user.save
            r.redirect '/users'
          else
            view('users/new')
          end
        end
        ##================================================== POST  ==================================================##
        r.get %r{posts/([0-9]+)} do |id|
          @post = Post[id]
          @user_name = @post.user.name
          view('posts/show')
        end

        r.redirect '/login' unless session[:user_id]

        r.on 'posts' do
          r.get 'new' do
            @post = Post.new
            view('posts/new')
          end
          r.post do
            @post = Post.new(r['post'])
            @post.user = User[session[:user_id]]

            if @post.valid? && @post.save
              r.redirect '/'
            else
              view('posts/new')
            end
          end

          r.on ':id' do |id|
            @post = Post[id]
            r.get 'edit' do
              view('posts/edit')
            end
            r.post do
              if @post.update(r['post'])
                r.redirect "/posts/#{@post.id}"
              else
                view('posts/edit')
              end
            end
          end
        end
      end
    end
  end
end
