defmodule MyAshBlog.Blog do
  use Ash.Domain, extensions: [AshJsonApi.Domain]

  resources do
    resource MyAshBlog.Blog.Post do
      define :create_post, action: :create
      define :list_posts, action: :read
      define :get_post, args: [:id], action: :by_id
      define :update_post, action: :update
      define :delete_post, action: :destroy

    end

    resource MyAshBlog.Blog.Comment do
      define :create_comment, action: :create
      define :list_comments, action: :read
      define :get_comment, args: [:id], action: :read
      define :update_comment, action: :update
      define :delete_comment, action: :destroy
    end

    resource MyAshBlog.Blog.Author do
      define :create_author, action: :create
      define :list_authors, action: :read
      define :get_author, args: [:id], action: :read
      define :update_author, action: :update
      define :delete_author, action: :destroy
    end

    resource MyAshBlog.Blog.User do
      define :create_user, action: :create
      define :list_users, action: :read
      define :get_user, args: [:id], action: :read
      define :update_user, action: :update
      define :delete_user, action: :destroy
    end

    resource MyAshBlog.Blog.AuthToken

  end



  json_api do
    routes do
      base_route "/post", MyAshBlog.Blog.Post do
        get :read
        index :read
        post :create
        delete :destroy
      end

      base_route "/author", MyAshBlog.Blog.Author do
        get :read
        index :read
        post :create
        delete :destroy
      end

      base_route "/users", MyAshBlog.Blog.User do
        get :read
        index :read
        post :create
        delete :destroy
      end

      base_route "/comment", MyAshBlog.Blog.Comment do
        get :read
        index :read
        post :create
        delete :destroy
      end
    end
  end
end
