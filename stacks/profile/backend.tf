terraform {
  backend "remote" {
    organization = "Bedatty-Engineering"

    workspaces {
      name = "profile"
    }
  }
}
