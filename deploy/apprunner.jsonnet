{
  ServiceArn: 'arn:aws:apprunner:us-west-2:861452569180:service/sponsor-app/4a7434fdd538498a9dee83d76f7a497f',
  SourceConfiguration: {
    ImageRepository: {
      ImageIdentifier: '861452569180.dkr.ecr.us-west-2.amazonaws.com/sponsor-app:' + std.extVar('IMAGE_SHA'),
      ImageRepositoryType: 'ECR',
    },
  },
}
