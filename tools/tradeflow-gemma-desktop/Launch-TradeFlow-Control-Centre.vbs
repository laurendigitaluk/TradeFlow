Option Explicit

Dim shell, fso, scriptPath, powershellPath, command, i, arg
Set shell = CreateObject("WScript.Shell")
Set fso = CreateObject("Scripting.FileSystemObject")

If WScript.Arguments.Count < 1 Then
    WScript.Quit 2
End If

scriptPath = WScript.Arguments(0)
If Not fso.FileExists(scriptPath) Then
    WScript.Quit 3
End If

powershellPath = shell.ExpandEnvironmentStrings("%SystemRoot%") & "\System32\WindowsPowerShell\v1.0\powershell.exe"
command = """" & powershellPath & """ -NoLogo -NoProfile -NonInteractive -ExecutionPolicy Bypass -WindowStyle Hidden -File """ & scriptPath & """"

For i = 1 To WScript.Arguments.Count - 1
    arg = WScript.Arguments(i)
    command = command & " """ & Replace(arg, """", """""") & """"
Next

' WScript.Run with window style 0 prevents a console window being shown.
' The Control Centre itself is a WinForms window and remains visible.
shell.CurrentDirectory = fso.GetParentFolderName(scriptPath)
shell.Run command, 0, False
