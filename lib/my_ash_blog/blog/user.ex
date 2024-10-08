defmodule MyAshBlog.Blog.User do
  use Ash.Resource,
    domain: MyAshBlog.Blog,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshJsonApi.Resource, AshAuthentication]

    import Ash.Resource.Actions

  postgres do
    table "users"
    repo MyAshBlog.Repo
  end

  resource do
    description "Resource dos usuários cadastrados no blog"
  end

  authentication do
    strategies do
      password :password do
        identity_field :email
        hashed_password_field :password
        sign_in_tokens_enabled? true
        confirmation_required? false
        register_action_accept [:username]
      end
    end

    tokens do
      enabled? true
      token_resource MyAshBlog.Blog.AuthToken
      signing_secret fn _, _ ->
        Application.fetch_env!(:my_ash_blog, :token_signing_secret)
      end
    end
  end

  identities do
    identity :unique_email, [:email]
    identity :unique_username, [:username]
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

    attribute :password, :string do
      allow_nil? false
      sensitive? true
      writable? true
      description "Senha do usuário. Será armazenada diretamente no banco"
    end

    timestamps()
  end

  relationships do
    has_many :comments, MyAshBlog.Blog.Comment do
      destination_attribute :user_id
      description "Relação um usuário tem vários comentários"
    end
  end

  actions do
    defaults [:read, :destroy]

    create :create do
      primary? true
      accept [:username, :email, :password]
      description "Cria um novo usuário com nome de usuário, email e senha" ##acao default, implementar aut
    end


    update :update do
      accept [:username, :email, :password]
      description "Atualiza o nome de usuário, email e senha de um usuário existente"
      require_atomic? false
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
