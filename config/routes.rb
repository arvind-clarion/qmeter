Rails.application.routes.draw do
  get 'report' => 'qmeter/report#index'
end