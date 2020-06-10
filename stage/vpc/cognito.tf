resource "aws_cognito_user_pool" "user_pool" {
  name = "kibana-userpool"
}

resource "aws_cognito_identity_pool" "identity_pool" {
  identity_pool_name               = "kibana identity pool"
  allow_unauthenticated_identities = false

  /*cognito_identity_providers {
    client_id               = "${aws_cognito_user_pool_client.kibana_client.id}"
    provider_name           = "cognito-idp.eu-west-1.amazonaws.com/${aws_cognito_user_pool.user_pool.id}"
    server_side_token_check = false
  }*/
}