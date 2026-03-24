terraform {
  backend "remote" {
    organization = "Bedatty-Engineering"

    workspaces {
      name = "ieq-va"
    }
  }
}
