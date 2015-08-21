Rails.application.routes.draw do
  get 'qmeter' => 'qmeter/report#index'
  get 'qmeter/js_cs' => 'qmeter/report#js_cs'
end