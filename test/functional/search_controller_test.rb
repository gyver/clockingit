require 'test_helper'

class SearchControllerTest < ActionController::TestCase
  fixtures(:users)
  
  context "a logged in user" do
    setup do
      @user = login
      @user.company.create_default_statuses

      project = project_with_some_tasks(@user)
      @task = project.tasks.first
    end

    should "include clients in search" do
      @user.company.customers.new(:name => "testclient").save!
      get :search, :query => "testclient"
      found = assigns["customers"]
      assert_equal 1, found.length
      assert_response :success
    end

    should "include users in search" do
      get :search, :query => @user.name
      assert_equal [ @user ], assigns("users")
      assert_response :success
    end

    should "include tasks in search" do
      get :search, :query => @task.name
      assert_equal [ @task ], assigns("tasks")
      assert_response :success
    end

    should "search tasks by id" do
      get :search, :query => @task.task_num
      assert_equal [ @task ], assigns("tasks")
      assert_response :success
    end

    should "include worklogs in search" do
      log = @task.work_logs.build(:company => @user.company,
                                  :body => "Test worklog", 
                                  :project => @task.project,
                                  :started_at => Time.now)
      log.save!
      get :search, :query => "worklog"
      assert_equal [ log ], assigns("logs")
      assert_response :success
    end

    should "include shouts in search" do
      channel = @user.company.shout_channels.build(:name => "test chan")
      shout = channel.shouts.build(:body => "shout")
      channel.save!
      get :search, :query => "shout"
      assert_equal [ shout ], assigns("shouts")
      assert_response :success
    end

    should "include wiki pages in search" do
      page = @user.company.wiki_pages.build(:name => "wiki page")
      page.revisions.build(:user => @user, :body => "wiki")
      page.save!
      get :search, :query => "wiki"
      assert_equal [ page ], assigns("wiki_pages")
      assert_response :success
    end

    should "include chats in search" do
      chat = @user.chats.build(:target => @user)
      msg = chat.chat_messages.build(:user => @user, :body => "chat msg")
      chat.save!
      get :search, :query => "msg"
      assert_equal [ msg ], assigns("chat_messages")
      assert_response :success
    end

    should "include forum posts in search" do
      forum = @user.company.forums.build(:name => "test forum")
      forum.save!
      topic = forum.topics.build(:title => "topic")
      topic.user = @user
      topic.save!
      post = topic.posts.build(:body => "post", :forum => forum)
      post.user = @user
      post.save!
      
      get :search, :query => "post"
      assert_equal [ post ], assigns("posts")
      assert_response :success
    end

    should "render search with no query" do
      get :search, :query => ""
      assert_response :success
    end

  end
end
