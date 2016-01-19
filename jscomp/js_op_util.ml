(* OCamlScript compiler
 * Copyright (C) 2015-2016 Bloomberg Finance L.P.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, with linking exception;
 * either version 2.1 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
 *)

(* Author: Hongbo Zhang  *)




(* Refer https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Operators/Operator_Precedence
  for precedence   
*)

let op_prec (op : Js_op.binop ) =
  match op with
  | Eq -> 1, 13, 1
  | Or -> 3, 3, 3
  | And -> 4, 4, 4
  | EqEqEq | NotEqEq -> 8, 8, 9
  | Gt | Ge | Lt | Le -> 9, 9, 10
  | Bor -> 5, 5, 5
  | Bxor -> 6, 6, 6
  | Band -> 7, 7, 7
  | Lsl | Lsr | Asr -> 10, 10, 11
  | Plus | Minus -> 11, 11, 12
  | Mul | Div | Mod -> 12, 12, 13

let op_int_prec (op : Js_op.int_op) = 
  match op with
  | Bor -> 5, 5, 5
  | Bxor -> 6, 6, 6
  | Band -> 7, 7, 7
  | Lsl | Lsr | Asr -> 10, 10, 11
  | Plus | Minus -> 11, 11, 12
  | Mul | Div | Mod -> 12, 12, 13


let op_str (op : Js_op.binop) =
  match op with
  | Bor     -> "|"
  | Bxor    -> "^"
  | Band    -> "&"
  | Lsl     -> "<<"
  | Lsr     -> ">>>"
  | Asr     -> ">>"
  | Plus    -> "+"
  | Minus   -> "-"
  | Mul     -> "*"
  | Div     -> "/"
  | Mod     -> "%"

  | Eq      -> "="
  | Or      -> "||"
  | And     -> "&&"
  | EqEqEq  -> "==="
  | NotEqEq -> "!=="
  | Lt      -> "<"
  | Le      -> "<="
  | Gt      -> ">"
  | Ge      -> ">="


let op_int_str (op : Js_op.int_op) = 
  match op with
  | Bor     -> "|"
  | Bxor    -> "^"
  | Band    -> "&"
  | Lsl     -> "<<"
  | Lsr     -> ">>>"
  | Asr     -> ">>"
  | Plus    -> "+"
  | Minus   -> "-"
  | Mul     -> "*"
  | Div     -> "/"
  | Mod     -> "%"
  
let str_of_used_stats = function
  | Js_op.Dead_pure ->  "Dead_pure"
  | Dead_non_pure -> "Dead_non_pure"
  | Exported -> "Exported" 
  | Used -> "Used"
  | Scanning_pure -> "Scanning_pure"
  | Scanning_non_pure -> "Scanning_non_pure"
  | NA -> "NA"

let update_used_stats (ident_info : J.ident_info) used_stats = 
  match ident_info.used_stats with 
  | Dead_pure | Dead_non_pure | Exported  -> ()
  | Scanning_pure | Scanning_non_pure | Used | NA  -> 
    ident_info.used_stats <- used_stats

let same_kind (x : Js_op.kind) (y : Js_op.kind)  =
  match x , y with
  | Ml, Ml
  | Runtime, Runtime -> true
  | External (u : string), External v ->  u = v 
  | _, _ -> false

let same_str_opt ( x : string option  ) (y : string option) = 
  match x ,y with
  | None, None -> true
  | Some x0, Some y0 -> x0 = y0
  | None, Some _ 
  | Some _ , None 
    -> false 
  
let same_vident (x : J.vident) (y : J.vident) = 
  match x, y with 
  | Id x0, Id y0 -> Ident.same x0 y0
  | Qualified(x0,k0,str_opt0), Qualified(y0,k1,str_opt1) -> 
      Ident.same x0 y0 && same_kind k0 k1 && same_str_opt str_opt0 str_opt1
  | Id _, Qualified _ 
  | Qualified _, Id _ -> false