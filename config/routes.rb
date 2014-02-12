NoteboxWeb::Application.routes.draw do

  root to: 'entries#index', as: :entries

  get '/new' => 'entries#new'

  # Entries
  scope '/entries/', controller: 'entries' do
    get  '/search' => :search
    get  '*path/edit' => :edit
    get  '*path/log' => :log

    get  '*path' => 'entries#show'
    post '*path' => 'entries#update'
  end

  # Images
  scope '/images', controller: 'images' do
    get '/' => :index
    get '*path.png' => :png
    get '*path/edit' => :edit
    get '*path' => :index
  end

  # Wiki
  scope '/wiki', controller: 'wiki' do
    get '/' => :index
    get '*path/edit' => :edit
    get '*path' => :show
  end

  # Attachments
  scope '/attachments', controller: 'attachments' do
    get '/' => :index, as: 'attachments'
    get '*path/edit' => :edit
    get '*path' => :show
  end

  # Bookmarks
  scope '/bookmarks', controller: 'bookmarks' do
    get  '/' => :index, as: 'bookmarks'
    get  '/new' => :new

    post '/' => :create
  end

  # Times
  scope '/timer', controller: 'timers' do
    get '/' => :index, as: 'timers'
    get  '/new' => :new, as: :new_timer
    put '*path' => :update
  end

  # Email
  get '/email' => 'emails#index'
  get '/backup' => 'backups#index'

  # DNS
  get '/dns' => 'dns#index'
  get '/dns/hosts' => 'dns#hosts'
  put '/dns' => 'dns#control'

  # Blocked Domain
  resources :blocked_domains, only: [:create, :update, :destroy]

  # Host Configuration
  put '/host_configuration' => 'host_configuration#update'

  match "*a", :to => "application#routing_error", via: [:get, :post]

end
