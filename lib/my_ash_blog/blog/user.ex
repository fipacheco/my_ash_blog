defmodule MyAshBlog.Blog.User do
  use Ash.Resource,
    domain: MyAshBlog.Blog,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshAuthentication, AshJsonApi.Resource, Ash.Resource.Dsl],
    authorizers: [Ash.Policy.Authorizer]

  postgres do
    table "users"
    repo MyAshBlog.Repo
  end

  resource do
    description "Recurso de usuários do blog, diferenciando usuários comuns, autores e admins."
  end

  authentication do
    strategies do
      password :password do
        identity_field :email
        hashed_password_field :hashed_password
      end
    end

    tokens do
      enabled? true
      token_resource MyAshBlog.Blog.AuthToken
      signing_secret fn _, _ ->
        secret = Application.fetch_env!(:my_ash_blog, :token_signing_secret)
        IO.inspect(secret, label: "Token Signing Secret")
        {:ok, secret}
      end
    end
  end

  attributes do
    uuid_primary_key :id do
      description "Identificador único do usuário"
    end

    attribute :role, :atom do
      allow_nil? false
      default :user
      description "Papel do usuário no sistema (:user ou :admin)."
      constraints one_of: [:user, :admin]
    end

    attribute :username, :string do
      allow_nil? true
      public? true
      description "Nome de usuário"
    end

    attribute :email, :string do
      allow_nil? false
      public? true
      description "Email do usuário"
    end

    attribute :hashed_password, :string do
      allow_nil? false
      sensitive? true
      description "Senha hasheada do usuário"
    end

    attribute :is_author, :boolean do
      allow_nil? false
      default false
      description "Indica se o usuário é um autor."
    end

    timestamps()
  end

  relationships do
    has_many :posts, MyAshBlog.Blog.Post do
      destination_attribute :user_id
      description "Relacionamento de um usuário com seus posts."
    end

    has_many :comments, MyAshBlog.Blog.Comment do
      destination_attribute :user_id
      description "Relacionamento de um usuário com seus comentários."
    end
  end

  actions do
    defaults [:read, :destroy]

    create :create do
      argument :password, :string, allow_nil?: false
      argument :password_confirmation, :string, allow_nil?: false

      accept [:email, :username, :role]

      validate confirm(:password, :password_confirmation)

      change fn changeset, _ctx ->
        case Ash.Changeset.get_argument(changeset, :password) do
          nil -> changeset
          password ->
            hashed_password = Bcrypt.hash_pwd_salt(password)
            Ash.Changeset.change_attribute(changeset, :hashed_password, hashed_password)
        end
      end
    end

    update :update do
      primary? true
      accept [:username]
      description "Atualiza os dados do usuário."
    end

    update :admin_update do
      accept [:username, :role, :is_author]
      description "Atualização completa dos dados do usuário (somente para admins)."
    end

    read :by_id do
      argument :id, :uuid, allow_nil?: false
      filter expr(id == ^arg(:id))
      description "Busca um usuário pelo ID."
    end
  end

  identities do
    identity :unique_email, [:email]
    identity :unique_username, [:username]
  end

  # Políticas de autorização
  policies do
    policy action_type(:create) do
      authorize_if always()
    end


    policy action_type(:read) do
      description "Usuários podem ler seus próprios dados. Administradores podem ler qualquer dado."
      authorize_if actor_attribute_equals(:role, :admin) ## aqui comprar um atributo de actor (no caso a role) com o parametro do atributo (no caso desta politica o role é admin)
    end

    # Esta política aqui tambem funciona e faz o mesmo
    # policy action_type(:read) do
    #   description "Usuários podem ler seus próprios dados. Administradores podem ler qualquer dado."
    #   authorize_if actor_attribute_equals(:role, :admin)
    #   authorize_if expr(id == ^actor(:id))
    #   forbid_unless expr(id == ^actor(:id) or role == :admin)
    # end

    # Permitir que usuários comuns atualizem apenas o username
    policy action_type(:update) do
      description "Usuários comuns podem atualizar apenas o campo `username`"
      authorize_if expr(id == ^actor(:id))
      forbid_unless always()
    end

    # Permitir que administradores atualizem qualquer campo
    policy action(:admin_update) do
      description "Administradores podem atualizar qualquer campo"
      #authorize_if expr(^actor(:role) == :admin)
      authorize_if always()
      #forbid_unless always()

    end

    policy action_type(:destroy) do
      description "Administradores podem excluir qualquer conta ou usuários podem excluir suas próprias contas"
      authorize_if expr(role == :admin or id == ^actor(:id))
    end
  end

  json_api do
    type "users"
  end
end
