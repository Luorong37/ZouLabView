# Zou Lab Hamamatsu Imaging App 用户与开发者手册

> **User and Developer Manual**  
> 文档版本：Draft 1.0，2026-09-01  
> 适用源码：`source/HamamatsuImagingApp.m`  
> 适用环境：MATLAB R2025a Update 1及当前实验室硬件配置

---

## 如何阅读本手册 / How to Use This Manual

本手册只有两个主要部分。

- **第一部分：用户手册**面向生物学专业本科生。只假定读者知道样品、相机、曝光和一次实验的基本概念，不要求理解MATLAB、DAQ或程序设计。
- **第二部分：Developer Manual**面向负责维护系统的博士研究生。它从整体架构开始，逐步说明代码位置、修改方法、测试和发布，不假定读者接受过专业软件工程训练。

第一次使用APP时，建议依次阅读用户手册第1～4章。准备视觉刺激、光刺激或DMD实验时，再阅读对应章节。只有需要修改程序时才需要阅读Developer Manual。

This manual has two main parts. The **User Manual** is written for biology students who understand basic experiments but not software development. The **Developer Manual** is written for research students who maintain the rig but are not professional software engineers. Read the quick workflow first; read architecture and source code only when you need to change or debug the application.

### 提示等级 / Notice Levels

> **提示（Note）**：帮助理解界面或数据。

> **重要（Important）**：可能改变实验结果、时间关系或数据解释。

> **警告（Warning）**：错误操作可能丢失数据、留下后台进程或使硬件保持未知状态。

> **硬件安全（Hardware safety）**：操作前必须确认光源、DAQ、DMD或相机的实际状态。

---

# 第一部分：用户手册 / Part I — User Manual

## 第1章 APP是什么 / What the App Does

### 1.1 一句话说明

Zou Lab Hamamatsu Imaging App用于在同一个界面中控制两台Hamamatsu相机、NI DAQ、成像光源、刺激激光、Psychtoolbox视觉刺激、LED Flicker和DMD，并保存可以追踪操作者和实验设置的数据。

当前相机分配为：

| 界面名称 | 实际设备 | 连接方式 |
|---|---|---|
| Camera 1 | Hamamatsu camera 1 | USB3 |
| Camera 2 | Hamamatsu camera 2 | CXP采集卡 |

APP支持三种基础成像模式：

- **Snap**：保存一次单帧图像。
- **Record**：以BIN格式连续保存高速图像。
- **Time Lapse**：按照设定间隔保存多个时间点。

它还可以在正式Record中加入：

- PTB屏幕视觉刺激；
- DAQ控制的LED Flicker；
- 405 nm或445 nm激光光刺激；
- DMD图案的内部播放或外部触发翻页。

### 1.2 界面布局

APP采用三列加底部固定区域的布局：

```text
┌──────────────────┬──────────────────┬────────────────────────┐
│ Camera 1 Preview │ Camera 2 Preview │ Home / Visual / Light  │
│ 相机1独立设置     │ 相机2独立设置     │ Advanced / Developer   │
├──────────────────┴──────────────────┼────────────────────────┤
│ Acquisition Timeline               │ Acquisition            │
└─────────────────────────────────────┴────────────────────────┘
```

- 左侧和中间分别显示两台相机，曝光、ROI、Bin、Preview和Snap都属于各自相机。
- 右侧上方通过标签页切换Home、Visual Stimulus、Light Stimulus、Advanced和Developer & Logs。
- 下方Timeline始终显示计划中的相机、DAQ、光源、AO、DMD和视觉刺激时序。
- Acquisition始终位于右下方，因此切换标签页时仍能看见当前采集模式和状态。

### 1.3 灯和状态文字

每个主要硬件都同时使用指示灯和文字。不要只看颜色。

| 常见状态 | 含义 |
|---|---|
| OFF / NOT CONNECTED | 没有连接或没有启用 |
| CONNECTING / WORKING | 命令已经收到，正在执行 |
| READY | 已连接，可以操作 |
| ARMED | 配置已冻结，下一次Acquisition会调用该模块 |
| RECORDING | 正在正式采集 |
| ERROR | 操作失败，需要阅读同一Panel的状态和日志 |

### English guide

The app combines two Hamamatsu cameras, NI DAQ, imaging and stimulation light sources, PTB, LED flicker and DMD control. Camera 1 is the USB camera and Camera 2 is the CXP camera. Camera controls remain inside each camera panel; experiment and stimulus controls are on the right; the timeline and acquisition controls remain visible at the bottom. Always read both the lamp and the state text.

---

## 第2章 实验前准备 / Before an Experiment

### 2.1 建议的开机顺序

1. 打开需要使用的相机电源。
2. 打开NI机箱或确认PCIe-6353在NI MAX中存在。
3. 如果需要成像光，打开Spectra X控制器。
4. 如果需要刺激激光，打开对应Coherent 405或445激光器。
5. 如果需要DMD，打开DMD控制器及其网络连接。
6. 打开MATLAB并启动APP。

不使用的硬件不必开启。APP允许：

- 单相机实验；
- 没有任何成像光的采集；
- 成像光强度为0；
- 只使用刺激光；
- Spectra X未连接时继续进行不依赖它的DAQ实验。

### 2.2 启动APP

普通用户可以双击：

```text
<repository-root>\HamamatsuImagingApp.mlapp
```

也可以在MATLAB中运行：

```matlab
cd('<repository-root>')
app = HamamatsuImagingApp;
```

### 2.3 登记用户

APP启动后，除用户登记区域外的操作会被锁定。

已有用户：

1. 在`Existing`下拉菜单选择姓名；
2. 点击`Start Session`；
3. 检查Operator指示灯和状态文字。

新用户：

1. 在`Name`输入姓名；
2. 点击同一个`Start Session`；
3. 检查是否显示Session已经开始。

用户名比较不区分大小写。例如`ExampleUser`和`exampleuser`视为同一用户。界面显示使用已保存的标准写法。

Session成功启动后，APP会自动尝试连接DAQ。DAQ连接失败不会撤销用户Session，也不会阻止与DAQ无关的功能；查看DAQ指示灯和错误文字，排除问题后可以用Home页的`Connect DAQ`手动重试。

> **重要**：不要使用他人的用户名。所有按钮点击、参数修改、硬件命令、实验结果和错误都会归属到当前用户。

### 2.4 选择保存位置

在Home页的Experiment & Save区域设置：

- `Mode`：Dual、Camera 1或Camera 2；
- `Save root`：实验根目录；
- `Note`：写入Record短名称的实验说明；
- `Cam1`和`Cam2`：相机标签，例如`cyan`、`red`。

Browse按钮应与Save root位于同一区域。选择根目录后，APP会在Acquisition参数变化时预估数据大小和需要的空间。

Home页不提供全局Method选择。PTB、LED Flicker、Laser和DMD的方法分别在对应子版面中选择，避免一个方法意外覆盖无关模块。Record开始时，APP会自动汇总各模块的实际设置以及相机和Acquisition参数。

### 2.5 开始前检查表

- 当前用户名正确；
- 保存目录正确且可写；
- 计划使用的相机已上电；
- 确认样品允许当前光照；
- 如果使用刺激，确认刺激参数和Cycle数；
- 确认磁盘剩余空间大于APP估算；
- 确认不需要的光源和DMD处于OFF。

### English guide

Power only the hardware needed for the experiment. Start the app, select or create your own user, start a session and choose a writable save root. The Home page has no global Method selector: choose PTB, LED Flicker, Laser, and DMD methods inside their respective sub-pages. The app deliberately allows acquisition without imaging light, at zero imaging intensity, or without Spectra X when the selected experiment does not require it. Never use another person's account because all actions and records are attributed to the active operator.

---

## 第3章 相机、Preview和Snap / Cameras, Preview and Snap

### 3.1 连接相机

1. 在Mode选择Dual、Camera 1或Camera 2。
2. 点击`Connect camera(s)`。
3. 等待每台目标相机旁的灯和文字变为READY。

相机身份根据序列号和总线确认，不能只根据MATLAB DeviceID判断。后来才打开第二台相机时，可以再次点击Connect；APP会尝试更新设备状态。

### 3.2 曝光、ROI和Bin

每台相机的设置位于自己的Preview下方。

#### Exposure

曝光时间单位为毫秒。当前预设为：

- 2.493 ms
- 10 ms
- 40 ms
- 100 ms
- Custom

曝光越长，通常图像越亮，但最大可能帧率越低。2.493 ms的倒数约为401 s⁻¹，但真实帧率还会受相机读出、ROI和触发模式影响。

#### ROI

ROI格式为：

```text
[x y width height]
```

预设包括512中心、1024中心、2304全画幅和Custom。ROI越小，相机通常可以越快读出。

#### Bin

Bin把相邻传感器像素合并。改变Bin时，APP按物理视场自动缩放ROI。应用后应检查相机模式文字中的实际尺寸。

#### Apply

编辑Exposure、ROI或Bin后点击对应相机的`Apply`。`Requested`表示界面请求值；只有`Actual`才表示相机已经确认。

### 3.3 启动Preview

每台相机有独立的：

- Preview
- Stop
- Snap

点击Preview后，成功过程应依次出现：

1. 按钮点击已收到；
2. Preview命令成功；
3. 第一幅完整`uint16`图像到达；
4. `Imaging: SUCCESS`。

`Imaging: SUCCESS`证明软件收到尺寸和类型正确、并具有灰度变化的帧。它不证明样品对焦、照明强度或实验质量正确。

### 3.4 对比度和转置

- `Auto`自动估计显示上下界；
- `Manual`使用用户输入的Low和High；
- Camera 1默认启用Transpose；
- 转置和对比度只影响屏幕显示；
- 保存的原始数据仍是未经转置的`uint16`。

### 3.5 怎样读FPS

界面显示三种不同含义的速度：

| 名称 | 测量位置 | 应怎样解释 |
|---|---|---|
| Stream | 相机/IAT采集计数 | 相机实际采集速度的主要指标 |
| View | 主界面收到并显示最新帧的速度 | 屏幕更新速度 |
| Record | 正式保存的帧数和持续时间 | 保存结果的实际速度 |

相机可以约400 FPS采集，而屏幕只以30～60 FPS刷新，这是正常的。Preview采用“最新帧”模式，不会把所有相机帧逐一显示，也不会因为跳过显示帧而自动造成Record丢帧。

### 3.6 Snap

Snap直接获取当前相机的一帧并保存为TIFF。双相机模式下，每台相机也可以使用自己Panel中的Snap按钮。Snap不自动开激光；用户必须确认当前照明状态适合成像。

### English guide

Connect the selected camera mode, then configure each camera independently. Apply exposure, ROI and bin settings before acquisition. Contrast and Camera 1 transpose are display-only operations; saved raw data remain untransposed `uint16`. Stream FPS measures camera acquisition, View FPS measures screen delivery, and Record FPS measures saved output. A 400-FPS stream with a 30–60-FPS view is expected.

---

## 第4章 Light Source和Registration / Illumination and Registration

### 4.1 Light Source表格

Home页Light Source表格把成像光和刺激光放在同一个硬件列表中。每一行可能包含：

- `Use`：本次配置是否使用该光源；
- `Channel`和`Alias`：硬件通道及实验名称；
- `Role`：Imaging、Stimulus或Off；
- `Camera`：成像光对应的相机；
- `%`或强度：当前设置；
- `State`：ON或OFF。

`Use=false`的行完全不参与本次实验，不会因Role或Camera字段阻止Acquisition。Stimulus光源不强制要求Camera映射。

### 4.2 Spectra X

Spectra X当前使用配置文件指定的串口。APP不自动搜索其他串口。如果找不到配置的端口，会提示检查USB连接和对应COM号。

表格只显示当前需要的Spectra通道。选择一行后，可用滑条或数值框调节成像光强度；松开滑条或提交数值后立即发送，不需要Apply按钮。

### 4.3 Coherent 405和445

两个刺激激光分别具有：

- DO数字门控：决定开或关；
- AO模拟输出：决定0～5 V强度命令。

Home页可以像成像光一样进行手动状态和强度控制。正式刺激波形应在Light Stimulus页设置，不依赖Home页的手动状态。

### 4.4 无光采集不是错误

APP不会仅因为以下情况阻止Acquisition：

- Spectra未连接；
- 没有任何Imaging光；
- Imaging强度为0；
- 只启用了Stimulus光。

这些配置会写入日志。操作者必须根据实验目的判断是否合理。

### 4.5 Registration

Registration用于修正两台相机观察位置的偏移。

- `Auto`：使用自动方法计算配准；
- `Manual`：在两台Preview图像上分别选择同一目标的多边形，计算质心差；
- `Load`：加载以前保存的配准结果。

Manual Registration的操作：

1. 保证两台相机已有可用图像；
2. 点击Manual；
3. 在Camera 1 Preview上依次点击多边形顶点；
4. 按Space切换到Camera 2；
5. 选择对应目标；
6. 按Enter完成；
7. 按R撤回最近操作。

计算会考虑Camera 1显示转置。完成后，临时ROI线条从Preview上清除。

### English guide

The light-source table includes both imaging and stimulation sources. Rows with `Use=false` are ignored. A missing Spectra connection, zero imaging intensity or no imaging light does not automatically block acquisition; the configuration is logged and the operator remains responsible for its scientific validity. Manual registration selects matching polygons on the two live preview axes and computes a centroid offset while accounting for display transpose.

---

## 第5章 Acquisition和数据保存 / Acquisition and Storage

### 5.1 三种模式

| 模式 | 用途 | 主要保存格式 |
|---|---|---|
| Snap | 一次单帧 | TIFF |
| Record | 连续高速成像 | BIN；可在全部Cycle结束后转换TIFF |
| Time Lapse | 多个间隔时间点 | 单帧TIFF |

### 5.2 Cycle和Start interval

`Cycles`表示重复多少次实验。`Start interval`表示一个Cycle开始到下一个Cycle开始之间的时间，而不是上一个Cycle结束后的额外等待时间。

Record开始时会先进入`PREPARING`：APP一次性建立全部Cycle目录、按预计帧数预留`.bin.part`文件，并启动常驻写盘线程。完成准备后才把Cycle 1定义为计时零点。因此文件分配和writer启动不会挤占Cycle 1到Cycle 2的Start interval。每个Cycle写完并校验后，`.bin.part`才发布为`.bin`；提前停止时，尚未开始Cycle的`.part`会被清理。

如果本次Cycle持续时间已经超过Start interval，APP不能创造负等待时间；应检查参数和日志。

每个Cycle建立独立文件夹：

```text
Rec1_note_yyMMddHHmm/
├─ Cycle1/
├─ Cycle2/
└─ Cycle3/
```

Cycle之间不会重新连接相机或自动恢复Preview。一次Record从Cycle 1到最后一个Cycle属于一个连续任务；休息期间显示倒计时。

### 5.3 Record duration

Record默认30秒。没有Armed刺激时，由用户设置Record时间。有些刺激模式会冻结或替代Record时间，使相机窗口与刺激计划一致。

### 5.4 Pre、Head、Stimulus、Tail和Post

时间轴中的区域含义：

```text
Pre-record | Light head | Stimulus | Light tail | Post-record
```

- Pre-record：刺激或成像光head之前额外保存的相机时间，默认0；
- Light head：光源先于刺激开启的时间；
- Stimulus：实际视觉或光刺激；
- Light tail：刺激结束后保持光源的时间；
- Post-record：光源结束后额外保存的相机时间。

DO和AO刺激波形的时间零点以Head结束为基准；各自的Start delay从该基准开始计算。Arm时根据冻结的完整窗口统一截断或补安全值。

### 5.5 BIN为什么用于Record

高速Record先写无文件头的`uint16` BIN，因为它比逐帧写压缩TIFF更适合连续数据。每个BIN旁边都有同名Info文件：

```text
Rec_001.bin
Rec_001.info.json
```

Info文件说明怎样读取BIN，包括：

- 高度、宽度和帧数；
- `uint16`、16 bit、little-endian；
- 无文件头；
- 相机、Cycle和分段编号；
- 文件创建和写入时间；
- 转换及视觉对齐状态。

### 5.6 TIFF转换

勾选`Convert Record BIN to TIFF after all cycles`后：

1. 所有Record Cycle先完成BIN采集；
2. APP启动后台裁切/转换；
3. 物理BIN裁切按Cycle并行，同一Cycle双相机仍作为一个可回滚事务；
4. TIFF转换按Cycle-相机单元由并行Worker处理；
5. 每个Worker独占自己的TIFF输出；
6. 某个单元验证成功后，只删除该单元对应的BIN；
7. `batch`本身占用1个协调Worker，因此进程池Worker数会同时受“本阶段任务数、物理核心、可用内存、Processes profile总槽位减1”限制；
8. 准备、采集、Cycle等待、排空和转换进度复用Developer & Logs页的状态文本，不新增Workflow区域。

转换默认关闭。后台裁切或转换期间不能启动新的Record，也不要手动移动BIN、Info或目标TIFF。

### 5.7 文件夹结构

典型Record：

```text
SaveRoot/
└─ Rec1_default_2609011200/
   ├─ methods/
   │  ├─ record_method.json
   │  ├─ method_manifest.json
   │  ├─ method_manifest.mat
   │  └─ modules/
   │     ├─ visual_ptb.json
   │     ├─ visual_led.json
   │     ├─ light_stim_laser.json
   │     └─ dmd.json
   ├─ record_manifest.json
   ├─ record_manifest.mat
   ├─ timeline.png
   ├─ daq_output.png
   ├─ daq_output.mat
   ├─ Cycle1/
   │  ├─ Cam1_cyan/
   │  │  ├─ Rec_001.bin
   │  │  └─ Rec_001.info.json
   │  └─ Cam2_red/
   └─ Cycle2/
```

`record_method.json`是本次Record的完整汇总。每个模块文件保存实际参数、选择的方法名、是否经过修改，以及该模块是否参与本次Record。未Arm的模块仍留存配置，但标记为`enabled_for_record=false`。同一Cycle超过单个分段大小时才出现`Rec_002.bin`。不同Cycle的BIN不会混写。

### 5.8 怎样判断成功

不要只看Start按钮是否返回。完整成功至少需要：

- 每台目标相机收到帧；
- 实际写入帧数与结果记录一致；
- BIN大小与Info一致；
- Writer正常关闭；
- Record状态为Completed；
- 如果请求TIFF，转换完成并验证输出。

### English guide

Snap and time-lapse points save TIFF directly. Continuous Record first enters `PREPARING`: it creates every Cycle folder, reserves planned segments as `.bin.part`, and starts the persistent writer tasks before the Cycle clock begins. A verified completed segment is then published as headerless `uint16` `.bin`; unused future `.part` files are removed after stop or failure. The Cycle interval is measured start-to-start from Cycle 1 after preparation. Every segment has a matching `.info.json` reader contract. Optional physical crop and TIFF conversion start only after all cycles finish. Crop runs in parallel by Cycle while retaining the two-camera transaction within each Cycle; TIFF conversion runs in parallel by Cycle-camera output. Existing Developer & Logs text reports preparation, capture, waiting, flushing and post-processing progress. A background post-processing job blocks a new Record. Each Record root stores one frozen `timeline.png`, exact `daq_output.mat`, compatible `daq_output.png`, a complete `methods/record_method.json`, and actual per-module method snapshots under `methods/modules/`.

---

## 第6章 Visual Stimulus / 视觉刺激

### 6.1 PTB Screen

PTB视觉刺激使用独立显示屏。使用顺序：

1. 打开Visual Stimulus页；
2. 选择`Screen / PTB`；
3. 设置Screen Index；
4. 点击`Set Screen`；
5. 确认PTB Screen指示灯和状态；
6. 配置Program、Duration、ISI、Repeats和角度；
7. 先Play Preview检查刺激；
8. 正式实验前点击Arm。

PTB空闲背景默认为黑色，ISI背景默认为灰色。Screen设置和Play是两个独立动作。`Set Screen`不自动播放刺激，`Play Preview`也不应该偷偷改变Screen选择。

### 6.2 PTB Method和播放模式

PTB Method只保存屏幕视觉刺激参数，不改变LED、Laser、DMD、相机或DAQ采样率。内置方法包括四向和八向Random drifting grating。用户方法保存在当前用户目录中。

Preview播放模式：

- Loaded program：播放当前完整程序；
- Fixed direction：播放指定角度；
- Random one direction：从角度列表随机选择一段。

开始Camera Preview后可以同时Play Preview视觉刺激。该模式不是DAQ同步实验，只用于观察相机在刺激期间的画面。

### 6.3 Arm是什么意思

Arm不是“锁死屏幕”，而是：

> 当前视觉刺激配置已经冻结，下一次点击Start Acquisition时会把它加入本次实验。

Armed后，Acquisition区域的Visual指示灯亮起。Disarm后，下一次Acquisition不再调用视觉刺激。

### 6.4 LED Flicker

LED Flicker位于Visual Stimulus中的`LED Flicker / DAQ`页。它不是屏幕闪烁，而是由DAQ控制配套LED模块。

LED Flicker Method只保存该页面的Delay、辅助生成参数、DO点表和AO频率/电压点表。它与PTB Method使用独立命名空间，因此可以使用相同名称。

- DO表控制LED Enable；
- AO表控制频率命令；
- 当前换算为`frequency_hz = voltage_v × 24`；
- 频率和电压都可以编辑，修改一个后自动计算另一个；
- Generate根据ON、OFF、Cycles和Frequency生成完整有限波形。

LED Flicker采用一次相机START后自由运行；相机START、LED DO和LED AO来自同一份有限DAQ输出矩阵，因此三者的相对时序由该矩阵直接定义。它不是逐帧触发相机，也不产生visual stamp。visual stamp仅用于把软件执行的PTB Flip连接到DAQ相机计数。

### 6.5 PTB与LED不能混淆

| 项目 | PTB | LED Flicker |
|---|---|---|
| 刺激设备 | 显示屏 | 外部LED模块 |
| 主要时序 | Screen Flip | NI DAQ DO/AO |
| Preview播放 | 支持 | 主要通过DAQ计划 |
| 对齐证据 | visual stamp、Flip记录、相机计数 | 同一DAQ矩阵中的相机START与LED DO/AO |

### English guide

Set the PTB screen before playback or arming. Standalone Play Preview can run while camera preview continues, but it is not a DAQ-synchronized experiment. Arming freezes the selected visual plan for the next acquisition. During acquisition, every PTB Flip emits a DAQ visual stamp so software display timing can be associated with the camera counters. LED Flicker is a separate DAQ-controlled physical LED stimulus with editable DO enable and AO frequency/voltage tables; camera START and LED outputs share one finite DAQ matrix, so LED Flicker neither uses visual stamps nor frame-by-frame camera triggers.

---

## 第7章 Light Stimulus和DMD / Light Stimulation and DMD

### 7.1 Light Stimulus的两个子模块

Light Stimulus页分为：

1. 激光DO/AO波形；
2. DMD校准、Mask、Pattern和播放。

两者可以独立使用，也可以在External DMD模式下通过DAQ组合。

### 7.2 激光DO波形

DO只表示数字开关。选择405或445后，可以用预设生成一个重复波形，也可以在表格中编辑时间点和0/1状态。

Laser Waveform Method只保存405/445选择以及DO、AO波形。DMD Method另行保存Mask、Pattern、播放和External IN1参数。载入Laser Method不会改变DMD；载入DMD Method不会改变Laser波形。DMD校准矩阵不属于可复用方法，但本次实验实际使用的校准文件、矩阵和SHA-256会写入Record汇总。

表格按钮包括新增、插入、删除、清空和恢复默认。最终波形由相邻点连接成分段常值数字信号。

### 7.3 激光AO波形

AO表示0～5 V强度命令，与DO独立。可以选择：

- Independent：AO使用自己的时间参数；
- Follow DO等其他同步方式，以界面实际选项为准；
- Linear：在拐点之间线性变化；
- 表格手动编辑任意时间-电压点。

预设只是帮助生成表格；Arm时真正使用的是最终表格，而不是预设名称。

### 7.4 Timeline Preview

Light Stimulus页的Show/Hide用于把当前草稿显示在Timeline。显示草稿不等于Arm，不会发送硬件命令。正式开始前必须检查：

- DO和AO从预期时间开始；
- Head和Tail正确；
- AO不超过5 V；
- 波形最后回到安全值0；
- 选中的通道与实际激光一致。

### 7.5 DMD Calibration

DMD Calibration用于建立相机全传感器坐标到DMD坐标的变换。每次实验可以重新校准，也可以加载历史校准。

校准流程：

1. Connect DMD；
2. 选择Standard Grid或Flipped Grid；
3. 播放网格；
4. 使用相机Snap作为Calibration source，或加载旧TIFF；
5. 在Preview上选择3个对应点；
6. Solve 3-point；
7. 把校准结果保存到当前Save root下的校准目录。

### 7.6 Mask Generation

当前Mask模式为`Manual`、`Threshold`、`Fiji ROI`和`Cellpose`。Manual模式在Preview上选择区域，操作提示显示在界面中：

- Space：继续下一个ROI；
- Enter：结束；
- R：撤回；
- Finish后清除Preview上的临时轮廓。

生成Each ROI时，APP会把每个ROI编译为DMD可以读取的图案序列：

- `Insert OFF frame after every ROI`关闭时，基础序列为`ROI1, ROI2, ...`；
- 打开时，基础序列为`ROI1, OFF, ROI2, OFF, ...`，最后一个ROI之后也有OFF；
- 默认使用完整基础序列循环补齐，上传图像数为“基础序列长度”和16的最小公倍数，因此不会只重复最后一个ROI；
- Advanced中的`Append trailing OFF frames (legacy block fill)`是另一项独立功能。打开后，最终不完整块改为在序列尾部追加暗图，而不是整段重复。它不会替代或关闭ROI之间的OFF选项；
- `Compile depth`位于Advanced，默认`1-bit binary`。

### 7.7 Internal和External播放

#### Internal

- DMD在内部循环播放已经加载的Pattern；
- 适合单个Mask持续显示；
- Timeline不生成IN1；
- Play、Pause和Stop由DMD Panel独立控制。

#### External IN1

- 每个有效上升沿使DMD翻到下一张图；
- 高电平后必须回到低电平，才能产生下一次上升沿；
- `DMD offset vs Camera START`是第一段IN1波形相对于相机START的有符号偏移。`0`表示第一枚上升沿与Camera START同起点，负值表示DMD先开始；
- `Trigger high`是高电平持续时间；`Trigger period`是相邻上升沿的间隔，低电平时间自动等于`period-high`；
- `Total IN1 triggers`是实际上升沿总数；`Pattern cycles = Total triggers / Binary frames per pattern`，允许显示小数，例如`100/48 = 2.0833 cycles`。修改任一项都会同步另一项；
- Generate会把指定触发数展开为完整的`Time / IN1 state / Expected frame`点表，不在运行时隐藏重复；
- 表格中的0/1状态是实际DAQ波形；Expected frame只用于检查和日志，修改它不能命令DMD跳到任意页；
- 修改生成参数会重新生成整张表；直接编辑表格时，已显示的Timeline会同步刷新；
- 默认情况下，点表结束后IN1保持LOW直到Record结束，不会自动循环。只有Advanced中的`Repeat IN1 train to fill Record`打开后，完整点表才重复并在Camera END处截断；
- Timeline显示IN1；
- Arm前检查端口、图案数量和触发数量。

### 7.8 DMD `-99`

如果DMD返回`-99`，可以使用界面中的管理员端口清理按钮。它调用项目内复制的：

```text
Zoulabview\tools\6002PortKill.bat
```

管理员操作后重新Connect。不要在DMD正在播放或实验正在采集时运行端口清理。

### English guide

Light stimulation uses independent digital gate and 0–5 V analog intensity waveforms. Presets generate editable point tables; the final tables are the authoritative armed waveforms. DMD calibration maps full-sensor camera coordinates to DMD coordinates using the two calibration grids and three selected points. Each-ROI compilation can optionally insert an OFF image after every ROI. By default the complete ROI/OFF sequence repeats to the least common multiple of its length and 16. The separate Advanced legacy option instead appends trailing OFF images to complete the last block. Internal playback does not create an IN1 timeline. External playback uses a fully expanded time/state table; every rising edge advances one binary frame and every falling edge restores LOW. DMD timing is camera-relative, trigger interval is editable, and trigger count is linked to a transparent fractional pattern-cycle value. A short IN1 train pads LOW by default; an Advanced opt-in can repeat it to Camera END.

---

## 第8章 Timeline、停止和故障处理 / Timeline, Stopping and Troubleshooting

### 8.1 Timeline怎样读

Timeline是计划图，不是所有硬件的实测反馈。

- DAQ DO和AO：正式输出矩阵的可视化；
- Camera START：计划发送的相机启动脉冲；
- DMD IN1：只有External模式才出现；
- PTB Visual：软件计划，不是DAQ输出；
- 绿色Record区域：Camera START固定为相对时间`0 s`，Camera END由Acquisition中的权威Record长度决定；
- Light DO、AO、DMD和成像TTL分别使用独立的Camera-relative offset。负偏移会让Timeline延伸到0秒左侧，未开始的其他列补安全值0。

Timeline不再降采样：界面、`timeline.png`和兼容的`daq_output.png`都使用编译后的全部DAQ采样点，`daq_output.mat`保存同一精确矩阵。长时间、高采样率计划的重绘因此更慢；参数编辑采用约250 ms防抖，在停止输入后只重绘一次。

Record总长由Acquisition中的`Record length source`决定：`Custom`使用`Record (s)`；`Light Stim DO`使用DO起点偏移加DO点表的最后时间。DMD永远不作为总长权威；DMD较短时默认补0，较长时在Camera END截断。

### 8.2 Stop Acquisition

Stop用于请求结束当前Acquisition。APP可能还需要完成：

- 停止输出；
- 把IAT中已经采集的帧排空；
- 关闭Writer；
- 写Info；
- 标记部分数据；
- 关闭光源。

因此点击Stop后不一定立即回到IDLE。应观察当前状态是否为Stopping、Flushing或Completed。

### 8.3 Safe Exit

红色`Safe Exit`是正常结束方法，并有二次确认。确认后APP应：

- 停止Preview、Time Lapse或Acquisition；
- 尽可能保留已采集数据；
- 把受控输出设置为安全OFF；
- 释放相机和DAQ；
- 关闭光源、DMD和PTB Screen；
- 保存用户设置；
- 刷新并关闭日志；
- 关闭后台服务和APP；
- 最后退出运行本APP的当前MATLAB会话，使该会话的`matlabwindowhelper`渲染进程一并退出。

Safe Exit会关闭当前MATLAB会话，因此同一会话中尚未保存的命令行变量、脚本或图窗也会关闭。独立启动的其他MATLAB进程不受影响。

### 8.4 右上角X

> **警告**：当前源码中的窗口右上角`X`是强制关闭界面的最后手段。它不显示确认，也不执行正常Safe Exit流程；它不会等待Writer、相机子进程或硬件复位。

使用X后，必须人工检查：

- 激光和Spectra是否实际关闭；
- DAQ输出是否回到安全值；
- DMD是否仍在播放；
- 是否存在后台MATLAB；
- 当前Record是否为不完整数据。

必要时由维护者使用项目提供的MATLAB清理脚本，再重新检查硬件。

### 8.5 从日志开始排错

Developer & Logs页显示：

- TIFF转换状态；
- APP结构化日志；
- Wiring JSON；
- 硬件和软件诊断信息。

用户报告问题时应提供：

1. 操作者姓名；
2. 大约发生时间；
3. 点击了哪个按钮；
4. 界面状态文字；
5. 本次APP主日志；
6. 如果涉及相机，提供相机服务日志目录；
7. 是否仍有光源、DMD或后台MATLAB运行。

### 8.6 常见现象

#### Stream正常但View下降

相机可能仍在采集，只是主界面忙。等待操作完成后Preview会跳到最新帧。

#### View和Stream都低

检查曝光、ROI、相机模式、触发方式和相机服务日志。

#### Start Acquisition不可用

首先检查用户Session、保存目录、目标相机、Acquisition状态和必要DAQ。不要只检查光源，因为无成像光本身不是阻止条件。

#### Spectra找不到

检查USB连接及`rig_wiring.json`指定COM口。APP不会自动改用其他COM口。

#### DMD不能Connect

检查网络配置、DMD电源、6002端口占用和`-99`日志。只在确认没有实验运行后使用管理员端口清理。

### English guide

The timeline is a plan. DAQ traces represent exact commanded outputs, whereas PTB is a software plan. Stop may be followed by flushing and metadata work. Safe Exit is the normal data-preserving shutdown. The window X currently closes the UI without normal hardware cleanup and must be treated as a last-resort force close. After using X, manually inspect all light, DAQ, DMD and child-MATLAB states.

---

# 第二部分：Developer Manual / Part II — Developer Manual

## 第9章 开发前必须理解的五件事 / Five Facts Before Editing

### 9.1 `.m`是源码，`.mlapp`是生成结果

项目的唯一主APP源码是：

```text
<repository-root>\source\HamamatsuImagingApp.m
```

发布文件是：

```text
<repository-root>\HamamatsuImagingApp.mlapp
```

`.mlapp`由`build_mlapp.m`从`.m`生成。不要直接在生成的`.mlapp`中长期维护代码，否则下一次构建会覆盖修改。

当前APP是程序化构建界面，不是传统Design View拖拽式项目。因此App Designer可能无法像普通`.mlapp`一样展示和编辑组件树。开发时使用MATLAB Editor编辑`.m`文件。

### 9.2 UI和硬件控制分开

`HamamatsuImagingApp`负责：

- 创建界面；
- 读取用户输入；
- 状态和按钮；
- 调用Controller；
- Timeline；
- 日志反馈。

`+zoulab`中的类负责相机、DAQ、光源、DMD、存储和Preset。不要把长时间硬件循环直接写进按钮callback。

### 9.3 主MATLAB不是唯一进程

真实硬件模式可能同时存在：

- 主MATLAB：UI、PTB、DAQ协调；
- 相机子MATLAB：长期拥有两台相机；
- Acquisition Worker或Writer Worker；
- TIFF转换Worker；
- DMD服务进程。

关闭UI不等于所有进程已经安全退出。

### 9.4 日志是程序接口的一部分

每个按钮点击、参数提交、状态转换、硬件命令和错误都应留下日志。新增功能但没有日志，视为功能没有完成。

### 9.5 数据意义优先

不得静默执行以下操作：

- 把`uint16`转为`uint8`；
- 转置或翻转保存数据；
- 归一化、裁剪或插值；
- 丢弃帧；
- 改变时间对齐锚点；
- 把不同Cycle混入同一个BIN。

如果必须改变，需在UI、日志、Info、manifest、测试和文档中同时说明。

### English guide

The canonical app source is `source/HamamatsuImagingApp.m`; the `.mlapp` is generated and may not behave like a normal Design View project. Hardware, storage and service logic belong in `+zoulab`. Real operation uses multiple MATLAB processes. Logging and preservation of raw-data meaning are mandatory parts of every implementation.

---

## 第10章 软件架构 / Architecture

### 10.1 总体数据流

```text
┌──────────────────────── Main MATLAB ─────────────────────────┐
│ HamamatsuImagingApp                                          │
│ UI / state / PTB / DAQ coordination / timeline / logging     │
│       │ localhost TCP commands        │ memmap latest frame   │
└───────┼────────────────────────────────┼───────────────────────┘
        ▼                                ▲
┌──────────────────── Camera child MATLAB ─────────────────────┐
│ CameraService → CameraManager → videoinput / IAT             │
│ PreviewSharedBuffer writer                                   │
│ Record drain → BufferedBinRecorder → writer queue → NVMe     │
└───────────────────────────────────────────────────────────────┘

Main MATLAB ── files/status ── Acquisition Worker / TIFF workers
Main MATLAB ── local service ── DMD Service ── DMD controller
Main MATLAB ── NI session ───── DAQ DO/AO/counters
```

### 10.2 TCP是什么

TCP是两个程序之间可靠传递小消息的方法。本项目的相机控制地址为`127.0.0.1:<动态端口>`：

- `127.0.0.1`只表示当前电脑；
- 不经过实验室网线；
- 动态端口每次启动可能不同；
- TCP传Connect、Preview、Record等命令和状态；
- 完整图像不通过TCP传输。

DMD也可以使用网络，但DMD地址与相机本机TCP不是同一个服务。不同服务使用独立端口和控制对象。

### 10.3 Preview邮箱

Preview像素使用`PreviewSharedBuffer`创建的双槽内存映射文件。全局头、两个槽头和两块固定形状的`uint16 [height,width]`帧区分别映射；不会把一整张图像换算成数百万个一维字节索引。可以把它理解成一个只保存“最新完整帧”的邮箱：

```text
Slot A：完整帧N
Slot B：正在写帧N+1
```

reader先读槽头，再按二维`uint16`数组复制固定槽，最后复查序号。如果写入过程中序号变化，就放弃这次读取，避免显示半帧。邮箱不保存历史，不适合Record。若相机子MATLAB意外退出，主程序会清除失效连接和映射；用户下一次明确点击Preview时会启动新的相机服务并重新连接，而不会沿用陈旧状态。

主MATLAB以`0.017 s`定时器（约58.8 Hz，不超过60 Hz）读取最新帧。每轮先更新所有可用相机的`image.CData`，再统一执行一次`drawnow nocallbacks`：它把待处理图形提交给渲染进程，但不在该点执行按钮等UI callback。这样可限制未提交图形命令的积压，同时避免Preview刷新重入用户操作。原始帧仍为完整分辨率`uint16`，没有为了显示而降采样。

### 10.4 IAT和Writer队列

IAT缓冲保存相机已经采集但尚未被程序取出的帧。Writer队列保存已经从IAT取出、等待写盘的数据块。两者是不同层：

```text
Camera → driver → IAT buffer → getdata/drain → writer queue → BIN
```

Writer队列不满并不代表IAT不会积压。可能的原因包括取帧循环没有及时运行、MATLAB调度、DAQ阻塞或过于频繁的检查。

### 10.5 PTB为什么与Writer分开

PTB Flip时间敏感。正式视觉Record时：

- 主MATLAB优先执行Flip和`stampVisualFrame()`；
- 相机子MATLAB继续采集和排空IAT；
- Writer在后台写BIN；
- Flip循环中不轮询Writer状态。

这样Writer查询不会直接插入PTB Flip的关键路径。

### English guide

The main MATLAB owns UI, PTB and orchestration. A persistent child MATLAB owns both camera `videoinput` objects. Small commands use localhost TCP, full preview pixels use a two-slot memory-mapped latest-frame mailbox, and Record frames flow from the IAT buffer into bounded writer queues and BIN files. PTB flip code does not poll the writer.

---

## 第11章 项目目录和代码入口 / Source Map

```text
Zoulabview/
├─ source/HamamatsuImagingApp.m
├─ HamamatsuImagingApp.mlapp
├─ build_mlapp.m
├─ +zoulab/
├─ config/rig_wiring.json
├─ tests/
├─ diagnostics/
├─ tools/
├─ docs/
├─ vendor/dmd/
├─ user_data/
├─ logs/
└─ tmp/
```

### 11.1 主文件职责

| 文件 | 主要职责 |
|---|---|
| `source/HamamatsuImagingApp.m` | UI、callback、状态和模块协调 |
| `build_mlapp.m` | 从权威`.m`生成`.mlapp` |
| `config/rig_wiring.json` | 当前Rig的DAQ、串口和DMD地址 |
| `+zoulab/AppLogger.m` | 结构化日志 |
| `+zoulab/SessionManager.m` | Record、Cycle、整体方法和模块快照 |
| `+zoulab/ModuleMethodManager.m` | 按用户和模块隔离的JSON方法库 |
| `+zoulab/CameraServiceClient.m` | 主进程相机代理、TCP和Preview reader |
| `+zoulab/CameraService.m` | 子进程命令服务和Record调度 |
| `+zoulab/CameraManager.m` | `videoinput`、IAT和相机硬件 |
| `+zoulab/PreviewSharedBuffer.m` | 双槽最新帧邮箱 |
| `+zoulab/BufferedBinRecorder.m` | 分块BIN写入 |
| `+zoulab/BinInfo.m` | BIN sidecar格式和验证 |
| `+zoulab/ParallelTiffConverter.m` | 后台并行TIFF转换 |
| `+zoulab/DaqLightController.m` | DAQ连接、DO/AO和counter |
| `+zoulab/StimulusWaveformCompiler.m` | 光刺激波形编译 |
| `+zoulab/VisualStimulusController.m` | PTB视觉程序 |
| `+zoulab/LedFlickerController.m` | LED DO/AO有限计划 |
| `+zoulab/DmdServiceClient.m` | 主APP到DMD服务 |
| `+zoulab/DmdCalibration.m` | 3点校准 |
| `+zoulab/DmdMaskGenerator.m` | Mask生成 |
| `+zoulab/DmdPatternCompiler.m` | DMD帧格式和补齐 |

### 11.2 从按钮寻找代码

推荐使用MATLAB Editor的Find Files或命令行`rg`搜索按钮Tag或文字。例如：

```powershell
rg -n "AcquisitionStartButton|startAcquisition" `
  <repository-root>\source\HamamatsuImagingApp.m
```

典型调用链：

```text
按钮创建
  → ButtonPushedFcn
  → app callback
  → Controller/Client
  → hardware or worker
  → status + log
```

### English guide

Use the source map to decide where a change belongs. UI and orchestration changes start in `HamamatsuImagingApp.m`; hardware, file format and service behavior belong in the corresponding `+zoulab` class. Search from a visible control's `Tag`, callback name or displayed text.

---

## 第12章 手动开发和构建 / Manual Development Workflow

### 12.1 修改前

1. 确认没有Acquisition或TIFF转换正在运行。
2. 使用Safe Exit关闭APP。
3. 检查是否存在不应保留的后台MATLAB。
4. 记录准备修改的文件、行为和验证范围。
5. 不要在同一次小修改中顺便重构无关模块。

### 12.2 在Editor打开源码

```matlab
projectRoot = '<repository-root>';
edit(fullfile(projectRoot,'source','HamamatsuImagingApp.m'));
```

### 12.3 运行源码版Simulation

```matlab
projectRoot = '<repository-root>';
addpath(projectRoot);
cd(fullfile(projectRoot,'source'));

app = HamamatsuImagingApp( ...
    'SimulationMode', true, ...
    'Visible', 'on');
```

Simulation可以验证：

- UI是否能创建；
- 控件是否遮挡；
- 回调和参数校验；
- Timeline；
- 文件夹和manifest；
- 日志；
- 一部分虚拟Record流程。

Simulation不能证明：

- 相机真实帧率；
- DAQ端口接线；
- 激光或Spectra实际输出；
- DMD反馈；
- PTB显示器实际Flip稳定性。

### 12.4 检查正在运行的是哪个类

MATLAB可能同时看到源码`.m`和旧`.mlapp`。修改后运行：

```matlab
which HamamatsuImagingApp -all
```

测试源码时，当前目录应为`source`。测试生成版时，当前目录应为项目根目录。切换前执行：

```matlab
clear app
clear classes
rehash
```

### 12.5 构建MLAPP

```matlab
cd('<repository-root>')
targetFile = build_mlapp();
```

构建脚本会：

1. 从`source`目录实例化Simulation APP；
2. 停止构建实例的timer；
3. 保存界面截图；
4. 使用R2025a内部App Designer serializer；
5. 覆盖生成`HamamatsuImagingApp.mlapp`。

构建必须出现：

```text
MLAPP_BUILD_SUCCESS
```

内部serializer可能输出关于AppBase对象保存/加载的警告。不能只根据警告判断构建失败；必须继续启动生成的`.mlapp`进行验证。

### 12.6 验证生成版

```matlab
clear classes
cd('<repository-root>')

app = HamamatsuImagingApp( ...
    'SimulationMode', true, ...
    'Visible', 'on');
```

至少检查：

- APP能打开；
- Home、Visual、Light、Advanced和Developer页都能切换；
- 两个相机Panel完整；
- PTB和LED页填满窗口；
- Acquisition和Timeline存在；
- Safe Exit Simulation可以关闭。

### English guide

Edit the canonical `.m` source in MATLAB Editor, run it from the `source` folder in Simulation Mode, use `which ... -all` to detect path shadowing, run tests, then rebuild from the project root with `build_mlapp`. Finally clear classes and launch the generated app from the root folder. A successful build message is not sufficient without a launch check.

---

## 第13章 如何修改UI和参数 / Changing UI and Parameters

### 13.1 修改布局

界面由`createComponents`和多个`create...Panel`、`create...Tab`函数创建。修改布局时：

- 使用`uigridlayout`；
- 使用`Layout.Row`和`Layout.Column`；
- 不依赖控件默认`Position`；
- 为复杂Tab增加一层填满父容器的Grid；
- 标签必须完整显示；
- 状态灯旁必须有文字；
- 表格应利用可用宽度；
- 小屏幕使用Scroll，不允许控件互相遮挡。

最近PTB和LED页曾经过小，就是因为Panel直接放入`uitab`后保留MATLAB默认约260×221像素。正确方法是：

```matlab
tabGrid = uigridlayout(tab, [1 1]);
tabGrid.RowHeight = {'1x'};
tabGrid.ColumnWidth = {'1x'};
tabGrid.Padding = [0 0 0 0];
panel = uipanel(tabGrid);
```

### 13.2 添加按钮

一个完整按钮至少包含：

```matlab
button = uibutton(parent, 'push', ...
    'Text', 'Clear', ...
    'Tag', 'ExampleClearButton', ...
    'ButtonPushedFcn', @(~,~) app.clearExample());
```

callback应遵循：

```text
记录点击
→ 显示Working
→ 校验状态和输入
→ 调用Controller
→ 更新状态
→ 记录Success或Error
```

不要让按钮静默失败，也不要只在Command Window输出结果。

### 13.3 添加可编辑参数

新增实验参数时，逐项检查：

1. UI控件和单位；
2. 合法范围；
3. `ValueChangedFcn`；
4. 旧值和新值日志；
5. 用户设置保存；
6. 用户设置恢复；
7. Arm后的冻结计划；
8. Timeline；
9. Record manifest；
10. 硬件Controller输入；
11. Simulation测试；
12. 真实硬件短测试。

只修改UI字段而没有把值传到编译器或Controller，会造成“看起来能编辑、实际上没有生效”的危险错误。

### 13.4 参数刷新和防抖

Timeline和空间估算使用约250 ms防抖。它表示“最后一次编辑后等待250 ms执行一次”，不是每250 ms轮询。高频文本编辑不要立即重复生成100个Cycle的完整图形。

### 13.5 用户设置

普通参数改变时标记设置为Dirty。完整用户设置主要在正常退出或切换用户时保存，而不是每次按键都写磁盘。关键用户操作仍立即进入日志队列。

### English guide

Programmatic UI changes belong in the relevant `create...` function and should use grid layouts rather than default pixel positions. Every new button needs visible feedback and logging. Every new experimental parameter must propagate through validation, settings, frozen plans, timeline, manifest, controller and tests. A field that edits only the UI is not a completed feature.

---

## 第14章 修改硬件和同步 / Hardware and Timing Changes

### 14.1 修改`rig_wiring.json`

接线文件是当前Rig的权威物理映射：

```text
Zoulabview\config\rig_wiring.json
```

它包含：

- DAQ Device ID；
- dummy AI；
- Camera START DO；
- visual stamp；
- DMD IN1；
- 光源DO；
- 405/445 AO；
- LED Flicker AO；
- counter输入；
- Spectra和OBIS串口；
- DMD网络地址。

修改步骤：

1. 断开受影响硬件；
2. 记录旧端口和新端口；
3. 编辑JSON；
4. 在Developer页Validate & Save；
5. 检查重复端口、缺失字段和电压范围；
6. Reload；
7. 单独连接一个硬件测试；
8. 最后进行组合测试。

不要沿用其他项目的端口值。未确认的可选连接应留空，而不是猜测。

### 14.2 当前关键映射

| 信号 | 当前映射 |
|---|---|
| Camera 1 START | `Dev1/port0/line10` |
| Camera 2 START | `Dev1/port0/line9` |
| Visual stamp | `Dev1/port0/line7` |
| DMD IN1 | `Dev1/port0/line8` |
| LED Flicker enable | `Dev1/port0/line4` |
| 405 DO | `Dev1/port0/line23` |
| 445 DO | `Dev1/port0/line11` |
| 405 AO | `Dev1/ao3` |
| 445 AO | `Dev1/ao2` |
| LED frequency AO | `Dev1/ao1` |
| Dummy input | `Dev1/ai0` |
| Camera 1 VSYNC | `Dev1/ctr2` |
| Camera 2 VSYNC | `Dev1/ctr1` |
| Visual stamp counter | `Dev1/ctr0` |

这些值只描述当前JSON。实际硬件改线后，必须同步更新配置、日志和手册。

### 14.3 输出和输入采样率

DAQ输出采样率和输入采样率可以不同：

- 输出采样率决定DO/AO波形时间分辨率；
- 输入任务使用2000 Hz dummy AI时钟并读取counter事件；
- 两者不要求数组长度相同；
- 但必须有明确的公共时间基准和事件对齐规则。

Timeline现在显示全部DAQ输出采样点，不再另设显示采样率。图形刷新速度仍不代表硬件输出速率；硬件速率以冻结计划和`daq_output.mat`中的`sample_rate_hz`为准。

### 14.4 修改同步规则前必须暂停决定

以下选择会改变实验含义，不能由Developer静默决定：

- 相机是START后自由运行还是逐帧触发；
- 对齐使用第一个VSYNC、PTB Flip还是visual stamp；
- 是否裁切Head或Tail；
- 计数不一致时保留还是删除数据；
- 不同长度Cycle如何比较；
- DMD触发不足时怎样补图案或补触发。

修改前应先写清楚方案，并取得实验负责人确认。

### English guide

The wiring JSON is the authoritative mapping for this rig. Edit it only while affected hardware is disconnected, validate duplicates and ranges, then test one device before integrated testing. Input, output and display sample rates are different concepts. Any change to trigger mode, event alignment or physical cropping changes experimental meaning and requires an explicit scientific decision.

---

## 第15章 修改相机、Preview和Record / Camera and Storage Development

### 15.1 相机所有权

真实硬件模式下，`CameraServiceClient`在第一次需要相机时启动隐藏子MATLAB。子进程中的`CameraService`和`CameraManager`持续拥有`videoinput`对象，直到Safe Exit。

不要在主APP中新建第二套真实`videoinput`，否则可能导致：

- adaptor占用冲突；
- DeviceID变化；
- Preview无法启动；
- DAQ触发目标错误；
- Safe Exit无法判断资源归属。

### 15.2 修改Preview

Preview关键路径：

```text
startCameraPreview
→ CameraServiceClient.startPreview
→ CameraService.startPreview
→ CameraManager
→ PreviewSharedBuffer.publish
→ remotePreviewTick
→ pollPreview
→ ingestPreviewFrame
→ image.CData
```

修改时保持：

- 原始类型`uint16`；
- 最新帧语义；
- 双槽完整性检查；
- 全分辨率传输；
- 2304尺寸发布上限30 FPS；
- 其他ROI发布上限60 FPS；
- Camera 1转置只发生在显示层；
- Auto Contrast不修改原始数据。

### 15.3 修改Record

Record关键层次：

```text
相机采集
→ IAT FramesAvailable
→ 分块getdata
→ 每相机Writer队列
→ 预分配BIN
→ 实际帧数截短文件
→ Info JSON
```

当前IAT保护原则是：如果积压接近计算容量的80%，请求保护性停止，而不是继续直到内存耗尽。更改该阈值会改变数据完整性和硬件保护策略，必须单独测试。

### 15.4 为什么不能每帧写日志

每帧日志会增加格式化、锁和磁盘负担，并让真正错误难以查找。应记录：

- 第一帧；
- 状态改变；
- 定期汇总；
- 队列或IAT异常；
- 丢帧或顺序错误；
- 最终计数。

### 15.5 修改BIN格式

任何BIN变化必须同时修改：

- `BufferedBinRecorder`；
- `BinInfo.create`和validator；
- TIFF converter；
- benchmark；
- tests；
- 用户手册；
- 分析端reader。

不要只改扩展名。

### English guide

The child MATLAB remains the sole real-camera owner. Preserve full-resolution `uint16`, latest-only preview delivery and display-only transpose. Record drains ordered IAT frames in blocks to per-camera writers. Any BIN-format change must update the writer, sidecar schema, validators, converter, tests, documentation and downstream reader.

---

## 第16章 日志、测试和发布 / Logging, Testing and Release

### 16.1 日志要求

推荐事件结构：

```text
timestamp | level | event_name | component | key=value
```

至少记录：

- APP启动、版本和Simulation状态；
- 用户Session；
- 每次按钮点击；
- 参数旧值和新值；
- 硬件身份、连接和断开；
- 请求值和实际值；
- 第一帧；
- Stream/View/Record健康信息；
- Arm冻结配置；
- Acquisition状态；
- 文件和帧数；
- Stop、Safe Exit和错误堆栈。

采集期间避免普通定时日志落盘；错误、停止和关键状态应尽可能保留。空闲时约每60秒刷新，Safe Exit强制刷新。

### 16.2 自动测试

```matlab
cd('<repository-root>')
results = runtests('tests');
table(results)
```

测试目录包括：

- APP UI和状态；
- Logger；
- PreviewSharedBuffer；
- CameraService；
- BufferedBinRecorder；
- Rig Wiring和Light Stimulus；
- DMD Calibration、Mask和Pattern。

### 16.3 分层硬件验证

不要从完整40分钟实验开始。推荐顺序：

1. 离线Simulation；
2. 单相机Preview；
3. 双相机Preview；
4. 单相机短Record；
5. 双相机短Record；
6. DAQ START和counter；
7. 单光源ON/OFF和强度；
8. PTB Play Preview；
9. PTB短Record；
10. LED Flicker短Record；
11. DMD Internal；
12. DMD External；
13. 多Cycle；
14. TIFF转换；
15. 长时间压力测试。

### 16.4 每次测试报告应写什么

- 日期和操作者；
- APP源码版本；
- MATLAB版本；
- 调用的硬件；
- 明确未调用的硬件；
- 参数和持续时间；
- 预期帧数与实际帧数；
- Stream/View/Record FPS；
- DAQ计数和视觉stamp；
- IAT和Writer异常；
- 输出文件；
- 是否清理大BIN；
- 最终结论及未验证部分。

### 16.5 发布检查表

1. 只包含已批准范围内的修改；
2. 源码静态检查通过；
3. 相关自动测试通过；
4. Simulation UI检查通过；
5. `.mlapp`重新构建；
6. 生成版可以启动；
7. 没有标签遮挡和空白表格列；
8. 新参数进入设置、日志、Timeline和manifest；
9. 硬件测试结果明确；
10. 文档和Change Log更新；
11. Safe Exit检查完成；
12. 未验证风险明确写出。

### 16.6 调试顺序

按数据流从前向后检查：

```text
用户点击
→ APP日志
→ 状态校验
→ Controller/Client命令
→ 子进程或硬件确认
→ 第一帧/DAQ事件
→ IAT排空
→ Writer
→ BIN/Info/manifest
→ 最终状态
```

不要看到最终文件缺失就立即重写Writer；先判断问题发生在哪一层。

### English guide

Logging must cover every user action, state transition and hardware result without logging every frame. Run automated tests first, then validate hardware from the smallest independent component to short integrated records and finally stress tests. Rebuild and launch-check the `.mlapp` before release, and clearly separate verified behavior from untested assumptions.

---

## 附录A：常用命令 / Common Commands

### 运行源码Simulation

```matlab
projectRoot = '<repository-root>';
addpath(projectRoot);
cd(fullfile(projectRoot,'source'));
app = HamamatsuImagingApp('SimulationMode',true,'Visible','on');
```

### 构建MLAPP

```matlab
cd('<repository-root>')
build_mlapp
```

### 运行测试

```matlab
cd('<repository-root>')
results = runtests('tests');
table(results)
```

### 检查类来源

```matlab
which HamamatsuImagingApp -all
```

### 查看MATLAB进程

```powershell
Get-Process matlab -ErrorAction SilentlyContinue |
    Select-Object Id,StartTime,Path
```

不要在不确认进程用途时终止全部MATLAB。实验室中可能同时存在AAA等其他独立程序。

---

## 附录B：术语表 / Glossary

| 术语 | 简明解释 |
|---|---|
| Acquisition | 一次正式采集任务 |
| Arm | 冻结配置，使下一次Acquisition调用该模块 |
| AO | 模拟电压输出，例如0～5 V激光强度 |
| BIN | 连续原始二进制图像文件 |
| Bin / Binning | 相机像素合并，不是BIN文件 |
| Callback | 点击按钮或timer到期后执行的函数 |
| Cycle | 同一Record任务中的一次重复实验 |
| DAQ | 数据采集与数字/模拟信号输出硬件 |
| DO | 数字0/1输出 |
| DMD | 数字微镜器件，用图案选择刺激区域 |
| FPS | 每秒帧数；必须区分Stream、View和Record |
| IAT | MATLAB Image Acquisition Toolbox及其采集缓冲 |
| Info sidecar | 描述同名BIN怎样读取的JSON文件 |
| Manifest | 记录方法、Record、设置和输出的结构化文件 |
| Preview | 实验前观察最新画面的显示路径 |
| PTB | Psychtoolbox，负责显示器视觉刺激 |
| ROI | 相机传感器上的读取区域 |
| Safe Exit | 正常停止、保存和释放硬件的退出路径 |
| TCP | 进程之间传小型命令和状态的可靠通信方式 |
| Timeline | 实验计划和DAQ输出的可视化 |
| VSYNC | 相机或显示设备的帧时序事件 |
| Worker | 在后台负责采集、写盘或转换的独立执行单元 |

---

## 附录C：已知边界 / Known Boundaries

- Preview成功不等于实验数据质量合格。
- View FPS不等于相机Stream FPS。
- PTB计划线不是DAQ实测输出。
- DMD OUT1当前未配置反馈，因此DMD实际翻页不能仅靠命令计划完全证明。
- Simulation不能替代真实硬件测试。
- 右上角X当前不是硬件安全退出；正常使用必须点击Safe Exit。
- 生成的`.mlapp`不是主要编辑入口，App Designer Design View支持有限。
- 未连接Spectra、无成像光或光强为0不会自动阻止实验；科学合理性由操作者负责。

---

## 文档维护规则 / Documentation Maintenance

以下变化必须同步更新本手册：

- UI标签、按钮或页面结构；
- 相机身份、DAQ端口、串口或DMD地址；
- 默认曝光、ROI、Cycle、Record或刺激参数；
- 数据格式或文件夹结构；
- 同步、裁切和对齐规则；
- Safe Exit或紧急关闭行为；
- 新硬件、新Preset或新测试流程。

Every release that changes user workflow, hardware mapping, timing meaning, file format or shutdown behavior must update this manual in the same change set.
