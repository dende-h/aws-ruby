terraform {
  backend "s3" {
    #下記を手順4で作成したS3の名前に書き換えてください
    bucket         = var.tfstate_storage 
    
    key            = "development/terraform.tfstate"
    region         = "ap-northeast-1"  
    encrypt        = true 
}
}