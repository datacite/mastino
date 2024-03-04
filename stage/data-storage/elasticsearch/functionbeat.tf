resource "aws_s3_bucket" "functionbeat-deploy-stage" {
    bucket = "functionbeat-deploy-stage"
    acl    = "private"
    policy = data.template_file.functionbeat.rendered
    tags = {
        Name = "FunctionbeatStage"
    }
}
