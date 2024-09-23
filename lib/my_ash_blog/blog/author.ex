defmodule MyAshBlog.Blog.Author do
  use Ash.Resource,
    domain: MyAshBlog.Blog,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "authors"
    repo MyAshBlog.Repo
  end

  attributes do
    uuid_primary_key :id

    attribute :name, :string do
      allow_nil? false
    end

    attribute :email, :string do
      allow_nil? false
    end

    timestamps()
  end

  actions do
    defaults [:read, :destroy]

    create :create do
      accept [:name, :email]
    end

    update :update do
      accept [:name, :email]
    end

    read :by_id do
      argument :id, :uuid, allow_nil?: false
      filter expr(id == ^arg(:id))
    end
  end
end
