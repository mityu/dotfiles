vim9script

export interface Predicate
  def Check(obj: any): bool
endinterface

export def Assert(obj: any, p: Predicate)
  if !p.Check(obj)
    throw $'TODO: construct message: typeguard is not satisfied: {obj}'
  endif
enddef

export def Ensure(obj: any, p: Predicate): any
  Assert(obj, p)
  return obj
enddef

class AsOptionalOf implements Predicate
  public var pred: Predicate

  def Check(obj: any): bool
    return this.pred.Check(obj)
  enddef
endclass

class IsTypeof implements Predicate
  var ty: number
  def Check(obj: any): bool
    return type(obj) == this.ty
  enddef
endclass

class IsListOf implements Predicate
  var itemPred: Predicate
  var pred: Predicate

  def new(p: Predicate)
    this.pred = IsTypeof.new(v:t_list)
    this.itemPred = p
  enddef

  def Check(obj: any): bool
    if !this.pred.Check(obj)
      return false
    endif
    for e in obj
      if !this.itemPred.Check(e)
        return false
      endif
    endfor
    return true
  enddef
endclass

class IsDictOf implements Predicate
  var form: dict<Predicate>
  var looks: Predicate

  def new(form: dict<Predicate>)
    this.form = form
    this.looks = IsTypeof.new(v:t_dict)
  enddef

  def Check(obj: any): bool
    if !this.looks.Check(obj)
      return false
    endif

    for [k, pred] in items(this.form)
      if has_key(obj, k)
        if !pred.Check(obj[k])
          return false
        endif
      elseif !instanceof(pred, AsOptionalOf)
        return false
      endif
    endfor
    return true
  enddef
endclass

class IsUnionOf implements Predicate
  var preds: list<Predicate>

  def Check(obj: any): bool
    for pred in this.preds
      if pred.Check(obj)
        return true
      endif
    endfor
    return false
  enddef
endclass

class IsSatisfies implements Predicate
  var Pred: func(any): bool

  def Check(obj: any): bool
    return this.Pred(obj)
  enddef
endclass

export const is: dict<Predicate> = {
  Bool: IsTypeof.new(v:t_bool),
  Channel: IsTypeof.new(v:t_channel),
  Dict: IsTypeof.new(v:t_dict),
  Float: IsTypeof.new(v:t_float),
  Func: IsTypeof.new(v:t_func),
  Job: IsTypeof.new(v:t_job),
  List: IsTypeof.new(v:t_list),
  None: IsTypeof.new(v:t_none),
  Number: IsTypeof.new(v:t_number),
  String: IsTypeof.new(v:t_string),
  Blob: IsTypeof.new(v:t_blob),
  Class: IsTypeof.new(v:t_class),
  Object: IsTypeof.new(v:t_object),
  Typealias: IsTypeof.new(v:t_typealias),
  Enum: IsTypeof.new(v:t_enum),
  Enumvalue: IsTypeof.new(v:t_enumvalue),
  Tuple: IsTypeof.new(v:t_tuple),
}

export const isof: dict<func(any): Predicate> = {
  ListOf: IsListOf.new,
  DictOf: IsDictOf.new,
  UnionOf: IsUnionOf.new,
  OptionalOf: AsOptionalOf.new,
  Satisfies: IsSatisfies.new,
}
