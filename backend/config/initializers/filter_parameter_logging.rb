Rails.application.config.filter_parameters += %i[
  passw email token secret credential otp ssn
]
