# lib/my_ash_phoenix_app/blog/post.ex

defmodule MyAshBlog.Blog.Post do
  use Ash.Resource,
    domain: MyAshBlog.Blog,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "posts"
    repo MyAshBlog.Repo
  end

  actions do
    defaults [:read, :destroy]

    create :create do
      accept [:title, :content]
    end

    update :update do
      accept [:content]
    end

    read :by_id do
      argument :id, :uuid, allow_nil?: false
      get? true
      filter expr(id == ^arg(:id))
    end
  end

  attributes do
    uuid_primary_key :id

    attribute :title, :string do
      allow_nil? false
    end

    attribute :content, :string

    timestamps()
  end
end
