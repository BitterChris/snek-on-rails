class StaticController < ApplicationController
  def index
    response = response_stuff

    render(json: response)
  end

  private

  def response_stuff
    <<-RESPONSE
    {
        "apiVersion": "1",
        "author": "Chrisoflurp",
        "color": "#D35400",
        "head": "shac-caffeine",
        "body": "bolt"
    }
    RESPONSE
  end
end
