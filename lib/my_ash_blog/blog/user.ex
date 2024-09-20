defmodule MyAshBlog.Blog.User do
  use Ash.Resource,
    domain: MyAshBlog.Blog,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "users"
    repo MyAshBlog.Repo
  end


  attributes do
    uuid_primary_key :id

    attribute :username, :string do
      allow_nil? false
    end

    attribute :email, :string do
      allow_nil? false
    end

    attribute :password, :string do
      allow_nil? false
      sensitive? true ## ash usa sensitive nao private!!
    end

    timestamps()
  end


  actions do
    defaults [:read, :destroy]

    create :create do
      accept [:username, :email, :password]
    end

    update :update do
      accept [:username, :email, :password]
    end
  end
end
