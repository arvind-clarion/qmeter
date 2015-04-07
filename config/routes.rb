Rails.application.routes.draw do
  get 'qmeter' => 'qmeter/report#index'
end