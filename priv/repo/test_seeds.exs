alias MyAshBlog.Repo
alias MyAshBlog.Blog.{User, Post, Comment}

# Criação de usuários
user1 = Repo.insert!(%User{
  username: "test_user1",
  email: "test_user1@example.com",
  hashed_password: "hashed_password1", # Normalmente você usaria uma senha hasheada
  role: "user"
})

user2 = Repo.insert!(%User{
  username: "admin_user",
  email: "admin_user@example.com",
  hashed_password: "hashed_password2",
  role: "admin" # Usuário admin que pode criar posts e deletar comentários
})

# Criação de posts
post1 = Repo.insert!(%Post{
  title: "Post de Teste 1",
  content: "Conteúdo do primeiro post de teste",
  user_id: user2.id # Associando ao usuário admin
})

post2 = Repo.insert!(%Post{
  title: "Post de Teste 2",
  content: "Conteúdo do segundo post de teste",
  user_id: user2.id # Associando ao usuário admin
})

# Criação de comentários
Repo.insert!(%Comment{
  content: "Comentário no primeiro post pelo test_user1",
  post_id: post1.id,
  user_id: user1.id
})

Repo.insert!(%Comment{
  content: "Comentário no segundo post pelo test_user1",
  post_id: post2.id,
  user_id: user1.id
})

Repo.insert!(%Comment{
  content: "Comentário no segundo post pelo admin_user",
  post_id: post2.id,
  user_id: user2.id
})

IO.puts("Seeds de teste inseridos com sucesso!")
