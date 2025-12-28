program CSSUnpacker;

uses
  Forms,
  main in 'main.pas' {Form2},
  cssunpack in '..\Source\cssunpack.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.Title := 'DM CSS Unpacker';
  Application.CreateForm(TForm2, Form2);
  Application.Run;
end.
