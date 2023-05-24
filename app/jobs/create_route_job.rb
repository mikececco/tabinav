class CreateRouteJob < ApplicationJob
  queue_as :default

  def perform(*args)
    puts "Job started"
    result = ChatgptService.call("Suggest a country to travel?")
    puts result
  end
end
