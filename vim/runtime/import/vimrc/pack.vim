vim9script

import 'vimrc.vim' as Vimrc

const PacPath = Vimrc.Fs.JoinPath(Vimrc.Stdpath.cache, 'pack', 'minpac', 'opt')

def ListInstalledPlugins(): dict<bool>
  var d: dict<bool> = {}
  const F = (e: dict<any>): number => {
    if e.type ==# 'dir'
      d[e.name] = true
    endif
    return 0
  }
  if isdirectory(PacPath)
    PacPath->readdirex(F, {sort: 'none'})
  endif
  return d
enddef

class Plugin
  # Treat plugins as not installed when 'loadplugins' option is off.
  static var _installedPlugins: dict<bool> =
        \ &loadplugins ? ListInstalledPlugins() : {}
  static var _fileSchemaLen = strlen('file://')

  var name: string
  var path: string
  var uri: string
  var config: dict<any>
  var isLazy: bool
  var isLocal: bool
  var isExists: bool
  var hooksOnLoad: list<func(): void>

  def new(name: string, uri: string, config: dict<any>, isLazy: bool)
    this.name = name
    this.uri = uri
    this.isLazy = isLazy
    this.config = config
    this.hooksOnLoad = []
    this.isLocal = this.uri[: _fileSchemaLen - 1] ==# 'file://'
    if this.isLocal
      this.path = this.uri[_fileSchemaLen :]->expand()
      this.isExists = this.path->isdirectory()
    else
      this.path = Vimrc.Fs.JoinPath(PacPath, name)
      this.isExists = _installedPlugins->has_key(name)
    endif
  enddef

  def IsLoaded(): bool
    const idx = &runtimepath->stridx(this.path)
    const ridx = idx + this.path->strlen()
    if idx == -1 ||
        !(idx == 0 || &runtimepath->strpart(idx - 1, 1) ==# ',') ||
        !(ridx == &runtimepath->strlen() || &runtimepath->strpart(ridx, 1) ==# ',')
      return false
    endif
    return true
  enddef
endclass

var pacPath: string = PacPath
var pluginList: dict<Plugin> = {}  # List of enabled plugins.
var minpacPluginList: list<Plugin> = []  # List of plugins that are not local.
var overriddenPluginList: dict<string> = {}

def AddCommon(uri: string, config: dict<any>, isLazy: bool)
  const name = uri->matchstr('/\zs[^/]\+$')
  const p = Plugin.new(name, uri, config, isLazy)
  if pluginList->has_key(name)
    echoerr 'Duplicate plugin name:' name
  endif
  pluginList[name] = p
  if !p.isLocal
    minpacPluginList->add(p)
  endif
enddef

export def Add(uri: string, config: dict<any> = {})
  AddCommon(uri, config, false)
enddef

export def AddLazy(uri: string, config: dict<any> = {})
  AddCommon(uri, config, true)
enddef

# Override already tapped plugin.  E.g. use development version
export def Override(target: string, uri: string, config: dict<any> = {})
  pluginList->remove(target)
  Add(uri, config)
  overriddenPluginList[target] = uri->matchstr('/\zs[^/]\+$')
enddef

# CAUTION: This function must be called at the last of vimrc.
export def LoadNonLazyPlugins()
  const pluginPath = pluginList
    ->values()
    ->filter((_: number, p: Plugin): bool => !p.isLazy && p.isExists)
    ->mapnew((_: number, p: Plugin): string => p.path)
  const afterPluginPath = pluginPath
    ->mapnew((_: number, v: string): string => Vimrc.Fs.JoinPath(v, 'after'))
    ->filter((_: number, v: string): bool => isdirectory(v))
  execute 'set runtimepath+=' .. (pluginPath + afterPluginPath)->join(',')

  # Enable ftplugin and syntax highlighting.  Note that this order DOES MATTER.
  filetype plugin indent on
  syntax enable
enddef

# Load a plugin.  If the plugin is already loaded, this function does nothing.
export def Load(name: string)
  const p = GetPlugin(name)
  if p == null_object
    echoerr 'Plugin not found:' name
  elseif !p.IsLoaded()
    execute 'packadd' name
  endif
enddef

export def Tap(name: string): bool
  const p = GetPlugin(name)
  return p != null_object && p.isExists
enddef

export def IsLoaded(name: string): bool
  const p = GetPlugin(name)
  return p != null_object && p.IsLoaded()
enddef

export def GetPlugin(nameGiven: string): Plugin
  const name = overriddenPluginList->get(nameGiven, nameGiven)
  return pluginList->get(name, null_object)
enddef

# minpac integrations.
export def InitMinpac(): bool
  const MinpacInspectJobs = () => {
    var nproc = 0
    if Vimrc.IsUnix && executable('nproc')
      nproc = str2nr(system(['nproc']))
    elseif Vimrc.IsWindows && $NUMBER_OF_PROCESSORS !=# ''
      nproc = str2nr($NUMBER_OF_PROCESSORS)
    endif
    return nproc ?? 8
  }
  const MinpacInit = () => minpac#init({
    progress_open: "tab",
    status_open: "vertical",
    status_auto: true,
    jobs: MinpacInspectJobs(),
  })
  silent! packadd minpac
  silent! MinpacInit()
  if !exists('*minpac#init()')
    # Download minpac...
    const minpacPath = Vimrc.Fs.JoinPath(pacPath, 'minpac')
    Vimrc.Mkdir(fnamemodify(minpacPath, ':h'), 'p')
    Vimrc.Echomsg('Downloading minpac...')
    system('git clone https://github.com/k-takata/minpac ' .. minpacPath)

    silent! packadd minpac
    silent! MinpacInit()
    if !exists('*minpac#init()')
      return false
    endif
  endif

  for p in minpacPluginList
    var config = p.config->copy()
    config.type = 'opt'
    minpac#add(p.uri, config)
  endfor

  return true
enddef

export def Update()
  if InitMinpac()
    const info = minpac#getpluginfo('vimdoc-ja')
    if !empty(info)
      system(printf('git -C %s reset --hard', shellescape(info.dir)))
    endif
    minpac#update()
  endif
enddef

export def Clean()
  if InitMinpac()
    minpac#clean()
  endif
enddef

export def Status()
  if exists('*minpac#status')
    minpac#status()
  else
    Vimrc.EchomsgError('minpac isn''t loaded yet.')
  endif
enddef
