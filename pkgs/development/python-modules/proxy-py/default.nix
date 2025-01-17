{ lib
, buildPythonPackage
, fetchFromGitHub
, openssl
, paramiko
, pytest-asyncio
, pytest-mock
, pytestCheckHook
, pythonOlder
, setuptools-scm
, typing-extensions
}:

buildPythonPackage rec {
  pname = "proxy-py";
  version = "2.4.0";
  format = "setuptools";

  disabled = pythonOlder "3.7";

  src = fetchFromGitHub {
    owner = "abhinavsingh";
    repo = "proxy.py";
    rev = "v${version}";
    sha256 = "sha256-VagX7ATVu6AT4POWoG9btizxFeBh9MLXiLpavtfXnyM=";
  };

  nativeBuildInputs = [
    setuptools-scm
  ];

  propagatedBuildInputs = [
    paramiko
    typing-extensions
  ];

  checkInputs = [
    openssl
    pytest-asyncio
    pytest-mock
    pytestCheckHook
  ];

  preCheck = ''
    export HOME=$(mktemp -d);
  '';

  postPatch = ''
    substituteInPlace requirements.txt \
      --replace "typing-extensions==3.7.4.3" "typing-extensions"
  '';

  pythonImportsCheck = [
    "proxy"
  ];

  meta = with lib; {
    description = "Python proxy framework";
    homepage = "https://github.com/abhinavsingh/proxy.py";
    license = with licenses; [ bsd3 ];
    maintainers = with maintainers; [ fab ];
  };
}
