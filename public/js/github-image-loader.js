function LocalStorageCache(expires) {
  this._expires = expires || 3600*1000 //1h
}
_.merge(LocalStorageCache.prototype, {
  _now: function() { 
    return (new Date).getTime();
  },

  _key: function(key) {
    return 'LocalStorageCache::'+key;
  },

  _expired: function(item) {
    return item.expires < this._now();
  },


  set: function(key, value, expires) {
    expires = (expires || this._expires);
    obj = {expires: this._now() + expires, value: value};
    localStorage.setItem( this._key(key), JSON.stringify(obj));
  },

  get: function(key) {
    item = JSON.parse(localStorage.getItem(this._key(key)));
    if (item && this._expired(item)) {
      localStorage.removeItem(this._key(key));
      return undefined;
    } 
    
    if (item && item.value) {
      return item.value;
    }
  }

})

function GithubImageLoader(config) {
  default_options = {}

  this._github = 'https://api.github.com'
  this._options = _.merge(default_options, config);
  this._cache = new LocalStorageCache();
}

_.merge(GithubImageLoader.prototype, {
  repo: function() {
    return this._options
  },

  opt: function(opt) {
    return this._options[opt]; //what do on missing?
  },

  query_string: function(parameters) {
    if (_.size(parameters) == 0) { return '' }

    return '?' + _.map(_.pairs(parameters), function(pair) {
      return pair.join('=');
    }).join('&')
  },

  build_url: function(api, endpoint, args, parameters) {
    if (typeof(args) === 'undefined') { args = []; }
    if (typeof(parameters) === 'undefined') { parameters = {}; }

    var url = [this._github, api, this.opt('user'), this.opt('repo'), endpoint].concat(args);
    url = url.join('/')

    if (_.size(parameters) > 0) {
      url = url + this.query_string(parameters);
    }

    return url;
  },

  api: function(api, endpoint, args, parameters) {
    url = this.build_url(api, endpoint, args, parameters);

    cached = this._cache.get(url);
    if (cached) {
      return $.Deferred().resolve(cached);
    } else {
      var _cache = this._cache;
      return $.getJSON(url).then(function(json) {
        _cache.set(url, json);
        return $.Deferred().resolve(json);
      });
    }
  },

  repos: function(endpoint, args, parameters) {
    return this.api('repos', endpoint, args, parameters);
  },

  repos_commits: function(args, parameters) {
    return this.api('repos', 'commits');
  },

  repos_trees: function(sha) {
    return this.repos('git/trees', sha, {recursive: 1})
  },

  raw_url: function(file) {
    return 'https://raw.githubusercontent.com/' + this.opt('user') + '/' + this.opt('repo') + '/gh-pages/' + file

  }
})

$().ready(function() {
  gh = new GithubImageLoader({user: 'sagotsky', repo: 'portfolio-jekyll'})
  gh.repos_commits().then( function(commits) {
    sha = commits[0]['sha']
    gh.repos_trees(sha).then(function(json) {
      files = _.filter(json.tree, function(node) {return (node.type == 'blob')});
      file_paths = _.map(files, function(node) {return node.path})

      carousel = _.filter(file_paths, function(f) {return f.match(/^_images\/carousel\//);})
      gallery = _.filter(file_paths, function(f) {return f.match(/^_images\/gallery\//);}) //does this file matching option work for detecting galleries?  seems too hacky for that.

      //need the url these actually live at...  
      //hadn't realized that this change will only work live.
      //also, static content is copied to _site.  maybe generator free isn't going to pan out.
      //https://raw.githubusercontent.com/sagotsky/portfolio-jekyll/master/_images/carousel/wallpaper.png
      carousel_urls = _.map(carousel, function(file) {return gh.raw_url(file);});
      carousel_html = _.map(carousel_urls, carousel_img)
      //$('.github-gallery.carousel').append(carousel_html)

      gallery_urls = _.map(gallery, function(file) {return gh.raw_url(file);});
      gallery_html = _.map(gallery_urls, gallery_img)
      //$('.github-gallery.gallery').append(gallery_html)

      //use a different gallery when it's provided.
      landscape_and_portrait = gallery_html.concat(_.map(carousel_urls, gallery_img))
      //$('.github-gallery.sample').append(_.shuffle(landscape_and_portrait))

     
      //this should live somewhere else.  doing it here since we know .gallery is full of images right now.
      $('a.fancybox').fancybox()
    });
  })
});

function carousel_img(href) {
  return '<a class="slide" href="'+href+'"><img src="'+href+'" /></a>';
}

function gallery_img(href) {
  return '<a class="fancybox" rel="fancybox1" href="'+href+'"><img src="'+href+'" /></a>';
}

