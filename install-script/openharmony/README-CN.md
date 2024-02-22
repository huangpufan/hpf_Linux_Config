# Open Harmony 环境安装配置指南

能够直接编译的环境有：

   - mini:
       - qemu-mini

   - small:
   
      - qemu
      暂没跑通
      - `kernel/liteos_a/fs/jffs2/build.gn`修改为这样
```
import("//kernel/liteos_a/liteos.gni")
module_switch = defined(LOSCFG_FS_JFFS)
module_name = get_path_info(rebase_path("."), "name")
linux_path = rebase_path("$KERNEL_LINUX_DIR")
out_path = rebase_path(target_out_dir)

kernel_module(module_name) {
  patch_path = rebase_path(".")
  cmd = "if [ -d ${out_path}/jffs2_build ]; then rm -r ${out_path}/jffs2_build; fi && mkdir -p ${out_path}/jffs2_build/fs"
  cmd += " && cp ${linux_path}/fs/jffs2 ${out_path}/jffs2_build/fs/. -r"
  cmd += " && cd ${out_path}/jffs2_build/"
  cmd += " && patch -p1 < ${patch_path}/jffs2.patch; cd -"
  exec_script("//build/lite/run_shell_cmd.py", [ cmd ])

```


   - standard:
    
      - sdk 

