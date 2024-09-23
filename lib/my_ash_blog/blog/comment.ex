defmodule MyAshBlog.Blog.Comment do
  use Ash.Resource,
    domain: MyAshBlog.Blog,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "comments"
    repo MyAshBlog.Repo
  end

  attributes do
    uuid_primary_key :id

    attribute :author, :string do
      allow_nil? false
    end

    attribute :content, :string do
      allow_nil? false
    end

    timestamps()
  end

  actions do
    defaults [:read, :destroy]

    create :create do
      accept [:author, :content]
    end

    update :update do
      accept [:author, :content]
    end

    read :by_id do
      argument :id, :uuid, allow_nil?: false
      filter expr(id == ^arg(:id))
    end
  end
end
