class jenkins::git {
  jenkins::plugin { "git-plugin" :
    name => "git";
  }
}

