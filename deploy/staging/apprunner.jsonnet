{
  ServiceArn: 'arn:aws:apprunner:us-west-2:861452569180:service/sponsor-app-staging/ffe708c6591a4039ad241e1016112f25',
  SourceConfiguration: {
    ImageRepository: {
      ImageIdentifier: '861452569180.dkr.ecr.us-west-2.amazonaws.com/sponsor-app:' + std.extVar('IMAGE_SHA'),
      ImageRepositoryType: 'ECR',
    },
  },
}
