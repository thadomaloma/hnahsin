Rails.application.routes.draw do
  root "dashboard#show"
  resource :session, only: %i[new create destroy]
  resource :dashboard, only: :show, controller: "dashboard"

  namespace :editorial do
    resources :content_items, only: %i[index show new create edit update] do
      resources :content_revisions, only: %i[show create] do
        member { post :submit }
        resources :review_decisions, only: %i[new create]
      end
    end
    resources :content_packs, only: %i[index show new create] do
      member { post :rollback }
    end
    get "word_images/:checksum", to: "word_images#show", as: :word_image,
      constraints: { checksum: /[0-9a-f]{64}/ }
    resource :bulk_game_modes, only: :create
    resources :flag_reviews, only: %i[index update]
    get "coverage", to: "coverage#show", as: :coverage
  end

  namespace :api do
    namespace :v1 do
      get "content_packs/latest", to: "content_packs#latest"
      resources :content_packs, only: :show, param: :public_id
      get "word_images/:checksum", to: "word_images#show", as: :word_image,
        constraints: { checksum: /[0-9a-f]{64}/ }
    end
  end

  get "up", to: "health#live"
  get "ready", to: "health#ready"
end
