defmodule MyAshBlog.Blog.User do
  use Ash.Resource,
    domain: MyAshBlog.Blog,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshJsonApi.Resource]

  postgres do
    table "users"
    repo MyAshBlog.Repo
  end

  resource do
    description "Resource dos usuários cadastrados no blog"
  end

  attributes do
    uuid_primary_key :id do
      description "Identificador único do usuário"
    end

    attribute :username, :string do
      allow_nil? false
      public? true
      description "Nome do usuário cadastrado. Campo obrigatório"
    end

    attribute :email, :string do
      allow_nil? false
      public? true
      description "Email do usuário cadastrado. Campo obrigatório"
    end

    timestamps()
  end

  actions do
    defaults [:read, :destroy]

    create :create do
      accept [:username, :email]
      description "Cria um novo usuário com nome de usuário e email"
    end

    update :update do
      accept [:username, :email]
      description "Atualiza o nome de usuário e o email de um usuário existente"
    end

    read :by_id do
      argument :id, :uuid, allow_nil?: false
      filter expr(id == ^arg(:id))
      description "Leitura de um usuário com base no ID fornecido"
    end
  end

  json_api do
    type "users"
  end
end
