# Hand Controlled Racecar Docker

https://github.com/user-attachments/assets/0eb432f5-b5ac-4838-9803-fe32edf42f49

Fork of [mit-rss/racecar_docker](https://github.com/mit-rss/racecar_docker), the Docker environment used in MIT's Robotics: Science and Systems (RSS) course. Modified to support gesture-based teleoperation via the [hand_controller](https://github.com/hcr-vvatel/hand_controller) ROS 2 package.

## What Was Modified
 
The base image runs MIT's racecar simulator (ROS 2 Humble + Gazebo) unmodified. The additions are the `hand_controller` package placed in the workspace under `home/racecar_ws/src/`, which publishes `AckermannDriveStamped` commands to `/drive` based on hand gestures and a ROS2 [USB Cam Driver](https://index.ros.org/p/usb_cam/) added as a service to `docker-compose.yml`, which reads and publishes frames from a usb source such as a web camera to `/image_raw`.

## Installation

First install `git` and Docker according to your OS:

- macOS: Make sure command line tools are installed by running `xcode-select --install` in a terminal and then
    [install and launch Docker Desktop](https://docs.docker.com/desktop/mac/install/).
- Windows: [Install git](https://git-scm.com/download/win) and then
    [install and launch Docker Desktop](https://docs.docker.com/desktop/windows/install/).
- Linux: Make sure you have [git installed](https://git-scm.com/download/linux) and then
    [install Docker Engine for your distro](https://docs.docker.com/engine/install).

Once everything is installed and running, if you're on macOS or Linux open a terminal and if you're on Windows open a PowerShell.
Then clone and pull the image:

> **IMPORTANT NOTE:** If you are using a Mac with Apple silicon, after cloning the repository, you must go into `docker-compose.yml`
> and change the image from "staffmitrss/racecar-sim:amd", to "staffmitrss/racecar-sim:arm"

```
git clone https://github.com/hcr-vvatel/hand_controlled_racecar_docker.git
cd racecar_docker
docker compose pull
```

Linux users may need to use `sudo` to run `docker compose`. The image is about 1GB compressed so this can take a couple minutes.
Fortunately, you only need to do it once.

## Using the Docker Container

### Starting Up

Once the image is pulled you can start it by running the following in your `racecar_docker` directory:

```
docker compose up
```

Follow the instructions in the command prompt to connect via either a terminal or your browser.
If you're using the browser interface, click "Connect" then right click anywhere on the black background to launch a terminal.

## Running the Simulation

First, connect via the graphical interface, right click on the background and select `RViz`.

> **Note:** RViz can also be launched by typing `rviz2` in the terminal. 

Next, right click on the background and select `Terminal`, then enter:

```
ros2 launch racecar_simulator simulate.launch.xml
```

A graphical interface should pop up that shows a blue car on a monochrome background (a map) and some colorful dots (simulated LiDAR).
If you click the green "2D Pose Estimate" arrow on the top and then drag on the map you can change the position of the car.

## Running with Hand Control
 
With the simulation already running, open a second terminal in the container (`docker compose exec racecar bash`) and run:
 
```bash
ros2 run hand_controller hand_controller
```
 
The node subscribes to `/image_raw` (webcam feed) and publishes drive commands to `/drive`. See [hand_controller](https://github.com/hcr-vvatel/hand_controller) for gesture reference.

### Shutting Down

To stop the image, run the following in your `racecar_docker` directory **outside of your docker container**:

```
docker compose down
```

**Do NOT use** `Ctrl+c` **to stop the docker container!** Always use the `docker compose down` command.
If you try to rerun `docker compose up` without first running `docker compose down` the image may not launch properly.
If you find that noVNC does not launch properly, try running `docker compose down` and then `docker compose up`.

## Troubleshooting: Webcam Not Available (Windows/WSL)
 
If `docker compose up` fails with:
 
```
Error response from daemon: error gathering device information while adding custom device "/dev/video0": no such file or directory
```
 
You're likely on Windows with WSL2. USB devices aren't available to WSL by default — you need to attach your webcam manually using `usbipd`.
 
Open PowerShell **as Administrator** and run:
 
```powershell
usbipd list
```
 
Find your webcam in the list and note its bus ID (e.g. `2-3`).
 
**First time only** — bind the device:
```powershell
usbipd bind --busid 2-3
```
 
**Every restart** — attach it to WSL:
```powershell
usbipd attach --wsl --busid 2-3
```
 
Binding is a one-time step that persists. Attaching is lost on every Windows restart and must be re-run each session before starting Docker. Then try `docker compose up` again. If `usbipd` is not installed, get it from [usbipd-win](https://github.com/dorssel/usbipd-win/releases).
