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

    attribute :password, :string do
      allow_nil? false
      sensitive? true
      public? true
      description "Senha do usuário. Campo Obrigatório"
    end

    timestamps()
  end

  actions do
    defaults [:read, :destroy]

    create :create do
      accept [:username, :email, :password]
      description "Cria um novo usuário com nome de usuário, email e senha"

      change fn changeset, _ctx ->
        password = Ash.Changeset.get_attribute(changeset, :password)
        hashed_password = Bcrypt.hash_pwd_salt(password)
        Ash.Changeset.change_attribute(changeset, :password, hashed_password)
      end
    end

    update :update do
      accept [:username, :email, :password]
      description "Atualiza o nome de usuário, email e senha de um usuário existente"
      require_atomic? false

      change fn changeset, _ctx ->
        case Ash.Changeset.get_attribute(changeset, :password) do
          nil ->
            changeset

          password ->
            hashed_password = Bcrypt.hash_pwd_salt(password)
            Ash.Changeset.change_attribute(changeset, :password, hashed_password)
        end
      end
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
