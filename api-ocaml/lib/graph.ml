module C = Cohttp_lwt_unix

open Graphql_lwt

type role 
	= User
	| Admin


(* let role = Schema.(enum "role"
  ~values: [
    enum_value "USER" ~value:User ~doc:"A regular user";
    enum_value "ADMIN" ~value:Admin ~doc:"An admin user";
  ]
) *)

let user = Schema.(obj "user"
	~fields: (fun _user -> [
		field "id"
			~args: Arg.[]
			~typ: (non_null int)
			~resolve: (fun () (p: User.t) -> p.id)
		;
		field "name"
			~args: Arg.[]
			~typ: (non_null string)
			~resolve: (fun () (p: User.t) -> p.name)
		;
	])
)

let account = Schema.(obj "account"
	~fields: (fun _account -> [
		field "id"
			~args: Arg.[]
			~typ: (non_null int)
			~resolve: (fun () (acc: Account.t) -> acc.id)
		;
		field "name"
			~args: Arg.[]
			~typ: (non_null string)
			~resolve: (fun () (p: Account.t) -> p.name)
		;
	])
)

let admin = Schema.(obj "admin"
	~fields: (fun _admin -> [
		io_field "investors"
			~args: Arg.[]
			~typ: (non_null (list (non_null user)))
			~resolve: (fun () () -> User.get_all () )
		;
		io_field "account"
			~args: Arg.[
				arg "id" ~typ: (non_null int)
			]
			~typ: account
			~resolve: (fun () () id -> Account.find_account id)
	])
)


(* https://andreas.github.io/ocaml-graphql-server/graphql/Graphql/Schema/index.html *)

let schema = Schema.(schema [

	io_field "users"
		~args: Arg.[]
		~typ: (non_null (list (non_null user)))
		~resolve: (fun () () -> User.get_all ())
	;

	field "admin"
		~typ: admin
		~args: Arg.[]
		~resolve: (fun () () ->
			Some ()
		)
	;

	field "greeter"
		~typ:string
		~args:Arg.[
			arg "config" ~typ:(non_null (obj "greeter_config" ~coerce:(fun greeting name -> (greeting, name)) ~fields: [
				arg' "greeting" ~typ:string ~default:"hello";
				arg "name" ~typ:(non_null string)
			]))
		]
		~resolve: (fun () () (greeting, name) ->
			Some (Format.sprintf "%s, %s" greeting name)
		)
		;
	]

	~mutations: [
		field "signUp"
			~args: Arg.[
				arg "input" 
					~typ: (non_null (obj "signUp_input"
						~coerce: (fun name username email password ->
							(name, username, email, password)
						) 
						~fields: [
							arg "name" ~typ: (non_null string);
							arg "username" ~typ: (non_null string);
							arg "email" ~typ: (non_null string);
							arg "password" ~typ: (non_null string);
						]
					)
				)
			]
			~typ: string
			~resolve: (fun () () _ -> Some(""))
		;
	]
)
